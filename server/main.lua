-- Core give/spawn/delete/move logic. Every public Core.* function is shared by
-- BOTH the dashboard (server/admin/api.lua) and the server-console commands
-- (server/commands.lua), so behaviour can never drift between the two paths.

Core = Core or {}

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end

----------------------------------------------------------------
-- Plate helpers
----------------------------------------------------------------
-- Returns the two stored representations of a plate: ends-trimmed (keeps the
-- internal space, e.g. "ABC 123") and the GTA 8-char right-padded form. We match
-- against both so lookups work no matter how a plate was persisted.
local function plateForms(plate)
    local trimmed = MSK.String.Trim(tostring(plate)):upper()
    local padded = trimmed
    if #padded < 8 then padded = padded .. string.rep(' ', 8 - #padded) end
    return trimmed, padded
end

DoesVehicleWithPlateExist = function(plate)
    local trimmed, padded = plateForms(plate)
    local count = MySQL.scalar.await(
        'SELECT COUNT(*) FROM owned_vehicles WHERE plate = ? OR plate = ?',
        { trimmed, padded }
    ) or 0
    return count > 0
end

local function generatePlate()
    if Config.Plate.format == 'XX XXXX' then
        if Config.Plate.enablePrefix then
            return Config.Plate.prefix .. ' ' .. math.random(1000, 9999)
        end
        return MSK.String.Random(2):upper() .. ' ' .. math.random(1000, 9999)
    end
    -- default 'XXX XXX'
    return MSK.String.Random(3):upper() .. ' ' .. math.random(100, 999)
end

-- In-memory reservation so two simultaneous gives can't grab the same plate
-- between the existence check and the INSERT.
local locks = {}
local function lock(plate)
    local trimmed = plateForms(plate)
    if locks[trimmed] then return false end
    locks[trimmed] = os.time()
    return true
end
local function unlock(plate)
    if plate then locks[plateForms(plate)] = nil end
end

-- Generates a free, unlocked plate (bounded retries).
local function generateUniquePlate()
    for _ = 1, 25 do
        local plate = generatePlate()
        if not locks[plateForms(plate)] and not DoesVehicleWithPlateExist(plate) and lock(plate) then
            return plate
        end
    end
    return nil
end

----------------------------------------------------------------
-- msk_garage bridge (read the shared DB table directly; no hard dependency)
----------------------------------------------------------------
function Core.IsGarageRunning()
    return GetResourceState('msk_garage') == 'started'
end

-- Resolves the msk_garage default garage for a vehicle type (read straight from
-- msk_garage_settings). Uses the per-category DefaultGarages map (land/sea/air),
-- falling back to the legacy single DefaultGarage. Returns nil if msk_garage is
-- absent or the resolved id no longer exists.
function Core.GetDefaultGarage(vehicleType)
    if not Core.IsGarageRunning() then return nil end
    local ok, rows = pcall(function()
        return MySQL.query.await(
            "SELECT `skey`, `svalue` FROM `msk_garage_settings` WHERE `skey` IN ('DefaultGarages', 'DefaultGarage')"
        ) or {}
    end)
    if not ok or type(rows) ~= 'table' then return nil end

    local defaults, legacy
    for _, r in ipairs(rows) do
        local okd, v = pcall(json.decode, r.svalue or 'null')
        if okd then
            if r.skey == 'DefaultGarages' then defaults = v
            elseif r.skey == 'DefaultGarage' then legacy = v end
        end
    end

    local id
    if type(defaults) == 'table' then
        id = defaults[AdminPerms.CategoryForType(vehicleType)]
    end
    if (not id or id == '') and type(legacy) == 'string' then id = legacy end

    if id and id ~= '' and Core.GetGarages()[id] then return id end
    return nil
end

-- Returns { [id] = { id, label, type = {...} } } or {} when msk_garage is absent.
function Core.GetGarages()
    if not Core.IsGarageRunning() then return {} end
    local out = {}
    local ok, rows = pcall(function()
        return MySQL.query.await('SELECT `id`, `label`, `data` FROM `msk_garage_garages` WHERE `enabled` = 1') or {}
    end)
    if not ok or type(rows) ~= 'table' then return {} end
    for _, row in ipairs(rows) do
        local okd, data = pcall(json.decode, row.data or '{}')
        local types = (okd and type(data) == 'table' and type(data.type) == 'table') and data.type or {}
        out[row.id] = { id = row.id, label = row.label or row.id, type = types }
    end
    return out
end

----------------------------------------------------------------
-- DB insert (dynamic columns: job/garage only when provided)
----------------------------------------------------------------
local function insertVehicle(owner, plate, props, vehicleType, job, garage)
    local trimmed = plateForms(plate)
    local cols = { 'owner', 'plate', 'vehicle', 'stored', 'type' }
    local vals = { '?', '?', '?', '?', '?' }
    local params = { owner, trimmed, json.encode(props), 1, vehicleType }

    if job then
        cols[#cols + 1] = 'job'; vals[#vals + 1] = '?'; params[#params + 1] = job
    end
    if garage and garage ~= '' then
        cols[#cols + 1] = 'garage'; vals[#vals + 1] = '?'; params[#params + 1] = garage
    end

    MySQL.insert.await(
        ('INSERT INTO owned_vehicles (%s) VALUES (%s)'):format(table.concat(cols, ', '), table.concat(vals, ', ')),
        params
    )
end

----------------------------------------------------------------
-- Pending capture requests. Vehicle PROPERTIES must be captured on a loaded
-- client (ESX.Game.GetVehicleProperties is client-only), so a give is a 2-step
-- handshake: dispatch capture -> client returns props -> store. The plate is
-- already validated & locked before dispatch, so the dashboard gets immediate
-- feedback on the common "plate already exists" failure.
----------------------------------------------------------------
local pending = {}
local reqSeq = 0
local PENDING_TIMEOUT = 12000 -- ms

local function clearPending(id)
    local p = pending[id]
    if not p then return end
    unlock(p.plate)
    pending[id] = nil
end

local function notify(src, message, typ)
    if src and src > 0 then Config.Notification(src, message, typ) end
end

-- opts: captureClient, targetId, type, model, plate?, garage?, job?, bool?,
--       notifySrc?, isItem?, itemName?, console?
function Core.Give(opts)
    local xTarget = ESX.GetPlayerFromId(opts.targetId)
    if not xTarget then return { ok = false, err = 'no_target' } end

    if type(opts.model) ~= 'string' or #opts.model == 0 then return { ok = false, err = 'bad_model' } end
    local vehicleType = tostring(opts.type or 'car')

    -- Owner: job vehicles owned by the job (bool '1') or by the player (bool '0').
    local owner
    if opts.job and #tostring(opts.job) > 0 then
        owner = (tostring(opts.bool) == '1') and opts.job or xTarget.identifier
    else
        owner = xTarget.identifier
    end

    -- Resolve & reserve the plate.
    local plate
    if opts.plate and #MSK.String.Trim(tostring(opts.plate)) > 0 then
        plate = MSK.String.Trim(tostring(opts.plate)):upper()
        if DoesVehicleWithPlateExist(plate) or not lock(plate) then
            return { ok = false, err = 'plate_exists' }
        end
    else
        plate = generateUniquePlate()
        if not plate then return { ok = false, err = 'plate_exists' } end
    end

    -- Garage: use the explicit choice, otherwise fall back to the msk_garage
    -- default garage for this vehicle type (so an empty/None field doesn't leave
    -- the vehicle garage-less). nil when msk_garage isn't running.
    local garage = opts.garage
    if (not garage or garage == '') then
        garage = Core.GetDefaultGarage(vehicleType)
    end

    reqSeq = reqSeq + 1
    local id = reqSeq
    pending[id] = {
        captureClient = opts.captureClient,
        owner = owner,
        type = vehicleType,
        model = opts.model,
        plate = plate,
        garage = garage,
        job = (opts.job and #tostring(opts.job) > 0) and opts.job or nil,
        notifySrc = opts.notifySrc,
        isItem = opts.isItem or false,
        itemName = opts.itemName,
        targetId = xTarget.source,
    }

    TriggerClientEvent('msk_givevehicle:admin:capture', opts.captureClient, { requestId = id, model = opts.model, plate = plate })

    -- Safety timeout: if the client never reports back, free the lock.
    SetTimeout(PENDING_TIMEOUT, function() clearPending(id) end)

    return { ok = true, plate = plate }
end

-- Client returned captured properties for a pending give.
RegisterServerEvent('msk_givevehicle:admin:captured', function(requestId, props)
    local src = source
    local p = pending[requestId]
    if not p or src ~= p.captureClient then return end
    if type(props) ~= 'table' then clearPending(requestId); return end

    -- Defensive: plate was locked, but re-check before the INSERT.
    if DoesVehicleWithPlateExist(p.plate) then
        clearPending(requestId)
        notify(p.notifySrc, Translation[Config.Locale]['vehicle_already_exist']:format(p.plate), 'error')
        return
    end

    props.plate = p.plate
    if props.fuelLevel == nil then props.fuelLevel = 100.0 end

    insertVehicle(p.owner, p.plate, props, p.type, p.job, p.garage)

    -- Auto key give.
    if Config.VehicleKeys and Config.VehicleKeys.enable then
        Keys.GiveKey({ identifier = p.owner }, p.plate, props.model)
    end

    if p.isItem and p.itemName then
        local xPlayer = ESX.GetPlayerFromId(p.targetId)
        if xPlayer then xPlayer.removeInventoryItem(p.itemName, 1) end
        notify(p.notifySrc, Translation[Config.Locale]['item_success'], 'success')
    else
        logging('debug', Translation[Config.Locale]['vehicle_successfully_added']:format(p.model, p.plate, p.targetId))
        notify(p.notifySrc, Translation[Config.Locale]['vehicle_successfully_added']:format(p.model, p.plate, p.targetId), 'success')
        if p.notifySrc and p.notifySrc == p.targetId then
            notify(p.targetId, Translation[Config.Locale]['got_vehicle']:format(p.model, p.plate), 'success')
        end
    end

    unlock(p.plate)
    pending[requestId] = nil
end)

-- Client failed to spawn the model (does not exist).
RegisterServerEvent('msk_givevehicle:admin:captureFailed', function(requestId, model)
    local src = source
    local p = pending[requestId]
    if not p or src ~= p.captureClient then return end
    notify(p.notifySrc, Translation[Config.Locale]['clientCommand']:format(model or p.model), 'error')
    clearPending(requestId)
end)

----------------------------------------------------------------
-- Spawn an owned vehicle by plate at a target player.
----------------------------------------------------------------
function Core.Spawn(opts)
    local xTarget = ESX.GetPlayerFromId(opts.targetId)
    if not xTarget then return { ok = false, err = 'no_target' } end

    local trimmed, padded = plateForms(opts.plate)
    local row = MySQL.single.await('SELECT * FROM owned_vehicles WHERE plate = ? OR plate = ? LIMIT 1', { trimmed, padded })
    if not row then return { ok = false, err = 'not_found' } end

    local okd, props = pcall(json.decode, row.vehicle)
    if not okd or type(props) ~= 'table' then return { ok = false, err = 'bad_data' } end

    TriggerClientEvent('msk_givevehicle:spawnVehicle', xTarget.source, props)
    MySQL.update.await('UPDATE owned_vehicles SET stored = 0 WHERE plate = ? OR plate = ?', { trimmed, padded })
    return { ok = true }
end

----------------------------------------------------------------
-- Delete an owned vehicle by plate.
----------------------------------------------------------------
function Core.Delete(opts)
    local trimmed, padded = plateForms(opts.plate)
    local affected = MySQL.update.await('DELETE FROM owned_vehicles WHERE plate = ? OR plate = ?', { trimmed, padded }) or 0
    if affected and affected > 0 then
        if Config.VehicleKeys and Config.VehicleKeys.enable then
            Keys.RemoveKey(trimmed)
        end
        logging('debug', Translation[Config.Locale]['deleted']:format(trimmed))
        return { ok = true }
    end
    logging('debug', Translation[Config.Locale]['delete_failed']:format(trimmed))
    return { ok = false, err = 'delete_failed' }
end

----------------------------------------------------------------
-- Move an owned vehicle into another msk_garage garage.
----------------------------------------------------------------
function Core.Move(opts)
    if not Core.IsGarageRunning() then return { ok = false, err = 'garage_unavailable' } end
    local garages = Core.GetGarages()
    local target = type(opts.garage) == 'string' and garages[opts.garage]
    if not target then return { ok = false, err = 'unknown_garage' } end

    local trimmed, padded = plateForms(opts.plate)
    local row = MySQL.single.await('SELECT `type` FROM owned_vehicles WHERE plate = ? OR plate = ? LIMIT 1', { trimmed, padded })
    if not row then return { ok = false, err = 'not_found' } end

    -- Light category check: the vehicle's category must be servable by the garage.
    if #target.type > 0 then
        local vehCat = AdminPerms.CategoryForType(row.type)
        local match = false
        for _, t in ipairs(target.type) do
            if AdminPerms.CategoryForType(t) == vehCat then match = true; break end
        end
        if not match then return { ok = false, err = 'type_mismatch' } end
    end

    MySQL.update.await('UPDATE owned_vehicles SET garage = ? WHERE plate = ? OR plate = ?', { target.id, trimmed, padded })
    return { ok = true }
end

----------------------------------------------------------------
-- Paginated, server-side filtered browse over owned_vehicles. Designed for
-- large tables (3000+ rows): owner/plate filters run in SQL, the page is small,
-- and the model filter matches the stored model hash so it stays a single scan.
----------------------------------------------------------------
function Core.Browse(opts)
    opts = type(opts) == 'table' and opts or {}
    local page = math.max(1, math.floor(tonumber(opts.page) or 1))
    local perPage = 25
    local offset = (page - 1) * perPage

    local q = type(opts.query) == 'string' and MSK.String.Trim(opts.query) or ''

    -- Builds WHERE + params for a single attempt. The name-search clause (which
    -- references the joined `users` table) is only emitted when `withUsers` is
    -- true, so the no-join fallback stays valid SQL.
    local function build(withUsers)
        local where, params = {}, {}
        if #q > 0 then
            local like = '%' .. q .. '%'
            if withUsers then
                where[#where + 1] = "(ov.plate LIKE ? OR ov.owner LIKE ? OR CONCAT(IFNULL(u.firstname,''),' ',IFNULL(u.lastname,'')) LIKE ?)"
                params[#params + 1] = like; params[#params + 1] = like; params[#params + 1] = like
            else
                where[#where + 1] = '(ov.plate LIKE ? OR ov.owner LIKE ?)'
                params[#params + 1] = like; params[#params + 1] = like
            end
        end
        if type(opts.garage) == 'string' and #opts.garage > 0 then
            where[#where + 1] = 'ov.garage = ?'; params[#params + 1] = opts.garage
        end
        if type(opts.vtype) == 'string' and #opts.vtype > 0 then
            where[#where + 1] = 'ov.`type` = ?'; params[#params + 1] = opts.vtype
        end
        if type(opts.model) == 'string' and #opts.model > 0 then
            -- Stored model is a joaat hash inside the vehicle JSON; it may be the
            -- signed or unsigned 32-bit form depending on the ESX version, so match both.
            local h = GetHashKey(opts.model)
            local unsigned = (h < 0) and (h + 4294967296) or h
            where[#where + 1] = '(ov.vehicle LIKE ? OR ov.vehicle LIKE ?)'
            params[#params + 1] = '%"model":' .. h .. '%'
            params[#params + 1] = '%"model":' .. unsigned .. '%'
        end
        return (#where > 0) and (' WHERE ' .. table.concat(where, ' AND ')) or '', params
    end

    local function run(withUsers)
        local whereSql, params = build(withUsers)
        local join = withUsers and ' LEFT JOIN users u ON u.identifier = ov.owner' or ''
        local total = MySQL.scalar.await(
            'SELECT COUNT(*) FROM owned_vehicles ov' .. join .. whereSql, params
        ) or 0
        local rows = MySQL.query.await(
            'SELECT ov.plate, ov.owner, ov.vehicle, ov.`type`, ov.stored, ov.garage, ov.job' ..
            (withUsers and ', u.firstname, u.lastname' or '') ..
            ' FROM owned_vehicles ov' .. join .. whereSql ..
            ' ORDER BY ov.plate LIMIT ' .. perPage .. ' OFFSET ' .. offset,
            params
        ) or {}
        return total, rows
    end

    local ok, total, rows = pcall(run, true)
    if not ok then
        -- users table/columns missing: degrade to no-join query.
        total, rows = run(false)
    end

    local out = {}
    for _, r in ipairs(rows or {}) do
        local name = nil
        if r.firstname or r.lastname then
            name = MSK.String.Trim(((r.firstname or '') .. ' ' .. (r.lastname or '')))
            if name == '' then name = nil end
        end
        out[#out + 1] = {
            plate = MSK.String.Trim(r.plate or ''),
            owner = r.owner,
            ownerName = name,
            type = r.type,
            stored = tonumber(r.stored) or 0,
            garage = r.garage,
            job = r.job,
        }
    end

    return {
        ok = true,
        rows = out,
        total = total or 0,
        page = page,
        perPage = perPage,
        pages = math.max(1, math.ceil((total or 0) / perPage)),
    }
end
