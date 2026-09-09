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

-- Every database access below goes through MSK.VehicleStore, which knows the
-- table and column layout of the running framework: owned_vehicles on ESX,
-- player_vehicles on QBCore and Qbox, where the properties live in `mods` and
-- the model in its own column. This resource used to speak ESX only.
DoesVehicleWithPlateExist = function(plate)
    return MSK.VehicleStore.CountByPlate(plate) > 0
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

    return MSK.VehicleStore.Insert({
        owner  = owner,
        plate  = trimmed,
        props  = props,
        model  = props and props.model,
        stored = true,
        type   = vehicleType,
        job    = job,
        garage = (garage and garage ~= '') and garage or nil,
    })
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
    local xTarget = MSK.GetPlayer(opts.targetId)
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
        local xPlayer = MSK.GetPlayer(p.targetId)
        if xPlayer then xPlayer.RemoveItem(p.itemName, 1) end
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
    local xTarget = MSK.GetPlayer(opts.targetId)
    if not xTarget then return { ok = false, err = 'no_target' } end

    local trimmed = plateForms(opts.plate)
    local vehicle = MSK.VehicleStore.GetByPlate(trimmed)
    if not vehicle then return { ok = false, err = 'not_found' } end

    local props = vehicle.props
    if type(props) ~= 'table' or not next(props) then return { ok = false, err = 'bad_data' } end

    TriggerClientEvent('msk_givevehicle:spawnVehicle', xTarget.source, props)
    MSK.VehicleStore.Update(trimmed, { stored = false })
    return { ok = true }
end

----------------------------------------------------------------
-- Delete an owned vehicle by plate.
----------------------------------------------------------------
function Core.Delete(opts)
    local trimmed = plateForms(opts.plate)

    if MSK.VehicleStore.Delete(trimmed) then
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

    local trimmed = plateForms(opts.plate)
    local vehicle = MSK.VehicleStore.GetByPlate(trimmed)
    if not vehicle then return { ok = false, err = 'not_found' } end

    -- Light category check: the vehicle's category must be servable by the garage.
    if #target.type > 0 then
        local vehCat = AdminPerms.CategoryForType(vehicle.type)
        local match = false
        for _, t in ipairs(target.type) do
            if AdminPerms.CategoryForType(t) == vehCat then match = true; break end
        end
        if not match then return { ok = false, err = 'type_mismatch' } end
    end

    MSK.VehicleStore.Update(trimmed, { garage = target.id })
    return { ok = true }
end

----------------------------------------------------------------
-- Change the ownership of an existing owned vehicle.
--   mode 'job'    -> society owned: owner becomes the job name (ESX reads such
--                    rows as society/job vehicles), job column is set as well.
--   mode 'player' -> owner becomes a player identifier; the job column can be
--                    kept, changed or cleared (pass job = nil to clear it).
-- opts: plate, mode, job?, identifier?
----------------------------------------------------------------
function Core.SetOwner(opts)
    local trimmed = plateForms(opts.plate)
    local vehicle = MSK.VehicleStore.GetByPlate(trimmed)
    if not vehicle then return { ok = false, err = 'not_found' } end

    local mode = (opts.mode == 'job') and 'job' or 'player'
    local job = nil
    if type(opts.job) == 'string' then
        local j = MSK.String.Trim(opts.job)
        if #j > 0 then job = j end
    end

    local owner
    if mode == 'job' then
        -- Society owned: the job IS the owner.
        if not job then return { ok = false, err = 'bad_job' } end
        owner = job
    else
        owner = type(opts.identifier) == 'string' and MSK.String.Trim(opts.identifier) or ''
        if #owner == 0 then return { ok = false, err = 'no_target' } end
    end

    -- Nothing to do (keeps the key handling below from firing needlessly).
    if owner == vehicle.owner and job == vehicle.job then
        return { ok = true, owner = owner, job = job, mode = mode }
    end

    -- Clearing the job writes a real NULL, so nothing keeps treating the row as
    -- a job vehicle. VehicleStore.Update skips nil values, so the clear needs
    -- its own explicit call.
    MSK.VehicleStore.Update(trimmed, { owner = owner, job = job })

    if not job then
        MSK.VehicleStore.ClearJob(trimmed)
    end

    -- Keys follow the owner: drop every key for the plate, then hand one to the
    -- new owner (identifier or job name, mirroring what Core.Give does).
    if Config.VehicleKeys and Config.VehicleKeys.enable then
        Keys.RemoveKey(trimmed)
        Keys.GiveKey({ identifier = owner }, trimmed, vehicle.model)
    end

    logging('debug', Translation[Config.Locale]['owner_changed']:format(trimmed, tostring(row.owner), owner))
    return { ok = true, owner = owner, job = job, mode = mode }
end

----------------------------------------------------------------
-- Paginated, server-side filtered browse.
--
-- The whole query lives in MSK.VehicleStore.Browse now, because the pieces it
-- has to get right differ per framework: the table, the column holding the
-- properties, the model filter (a JSON scan on ESX, an indexed hash comparison
-- on QBCore and Qbox) and the join that resolves the owner name, which comes
-- from name columns on ESX and out of a JSON field on the other two.
----------------------------------------------------------------
function Core.Browse(opts)
    opts = type(opts) == 'table' and opts or {}

    local perPage = 25
    local result = MSK.VehicleStore.Browse({
        page    = opts.page,
        perPage = perPage,
        query   = opts.query,
        garage  = opts.garage,
        type    = opts.vtype,
        model   = opts.model,
    })

    local out = {}

    for _, vehicle in ipairs(result.vehicles or {}) do
        local name = vehicle.ownerName and MSK.String.Trim(vehicle.ownerName) or nil
        if name == '' then name = nil end

        out[#out + 1] = {
            plate = MSK.String.Trim(vehicle.plate or ''),
            owner = vehicle.owner,
            ownerName = name,
            type = vehicle.type,
            stored = vehicle.stored and 1 or 0,
            garage = vehicle.garage,
            job = vehicle.job,
        }
    end

    local total = result.total or 0

    return {
        ok = true,
        rows = out,
        total = total,
        page = result.page or 1,
        perPage = perPage,
        pages = math.max(1, math.ceil(total / perPage)),
    }
end
