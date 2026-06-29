AdminApi = AdminApi or {}

----------------------------------------------------------------
-- Input sanitisation. NEVER trust client structures.
----------------------------------------------------------------
local ID_PATTERN = '^[%w_%-]+$'

local function bool(v) return v == true end

local function str(v, max)
    if type(v) ~= 'string' then return nil end
    if #v > (max or 120) then v = v:sub(1, max or 120) end
    return v
end

local function oneOf(value, list, fallback)
    if type(value) == 'string' then
        for _, v in ipairs(list) do
            if v == value then return value end
        end
    end
    return fallback
end

local function inList(value, list)
    for _, v in ipairs(list) do if v == value then return true end end
    return false
end

----------------------------------------------------------------
-- Settings
----------------------------------------------------------------
function AdminApi.SanitizeSettings(patch)
    local out = {}
    if type(patch) ~= 'table' then return out end

    for _, key in ipairs(AdminPerms.SETTINGS_KEYS) do
        local v = patch[key]
        if v ~= nil then
            if key == 'Locale' then
                local LOCALES = { de = true, en = true }
                if LOCALES[v] then out[key] = v end
            elseif key == 'FuelSystem' then
                out[key] = oneOf(v, AdminPerms.FUEL_SCRIPTS, Config.FuelSystem or AdminPerms.FUEL_SCRIPTS[1])
            elseif key == 'adminCommand' then
                local cmd = str(v, 32)
                if cmd and cmd:match('^[%w_]+$') then out[key] = cmd end
            elseif key == 'BrandTag' then
                local tag = str(v, 16)
                if tag ~= nil then out[key] = tag:gsub('[%c]', '') end
            elseif key == 'Plate' then
                if type(v) == 'table' then
                    local cur = type(Config.Plate) == 'table' and Config.Plate or {}
                    local prefix = str(v.prefix, 4) or cur.prefix or 'PX'
                    out[key] = {
                        format = (v.format == 'XX XXXX') and 'XX XXXX' or 'XXX XXX',
                        enablePrefix = bool(v.enablePrefix),
                        prefix = prefix:gsub('[%s%c]', ''),
                    }
                end
            elseif key == 'VehicleKeys' then
                if type(v) == 'table' then
                    local cur = Config.VehicleKeys or {}
                    out[key] = {
                        enable = bool(v.enable),
                        script = oneOf(v.script, AdminPerms.VEHICLEKEY_SCRIPTS, cur.script or AdminPerms.VEHICLEKEY_SCRIPTS[1]),
                    }
                end
            elseif key == 'Theme' then
                if type(v) == 'table' then
                    local cur = (type(Config.Theme) == 'table') and Config.Theme or AdminPerms.DEFAULT_THEME
                    local theme = {}
                    for _, ck in ipairs(AdminPerms.THEME_KEYS) do
                        local hex = type(v[ck]) == 'string' and v[ck]:match('^#%x%x%x%x%x%x$')
                        theme[ck] = hex or cur[ck] or AdminPerms.DEFAULT_THEME[ck]
                    end
                    out[key] = theme
                end
            else
                -- Boolean flags: Debug, VersionChecker
                out[key] = bool(v)
            end
        end
    end
    return out
end

----------------------------------------------------------------
-- Items (Config.Vehicles)
----------------------------------------------------------------
function AdminApi.SanitizeItem(input)
    if type(input) ~= 'table' then return nil, 'bad_input' end
    local id = input.id
    if type(id) ~= 'string' or #id == 0 or #id > 60 or not id:match(ID_PATTERN) then return nil, 'bad_id' end
    local model = str(input.model, 60)
    if not model or #model == 0 then return nil, 'bad_model' end
    return {
        id = id,
        label = str(input.label, 120) or id,
        model = model,
        categorie = oneOf(input.categorie, AdminPerms.VEHICLE_TYPES, 'car'),
    }
end

----------------------------------------------------------------
-- Bootstrap / payloads
----------------------------------------------------------------
function AdminApi.SettingsPayload()
    local out = {}
    for _, key in ipairs(AdminPerms.SETTINGS_KEYS) do out[key] = Config[key] end
    out.dashboardGroups = Config.dashboardGroups or {}
    return out
end

function AdminApi.ItemsArray()
    local out = {}
    for id, def in pairs(Config.Vehicles or {}) do
        out[#out + 1] = { id = id, label = def.label or id, model = def.model or id, categorie = def.categorie or 'car' }
    end
    table.sort(out, function(a, b) return a.id < b.id end)
    return out
end

function AdminApi.GroupsArray()
    local out = {}
    out[#out + 1] = { name = 'admin', protected = true, perms = AdminPerms.AllPerms() }
    for name, matrix in pairs(AdminStore.perms) do
        if name ~= 'admin' then
            out[#out + 1] = { name = name, protected = false, perms = matrix }
        end
    end
    return out
end

function AdminApi.JobsList()
    local out = {}
    local jobs = (ESX and ESX.GetJobs) and ESX.GetJobs() or {}
    for name, job in pairs(jobs) do
        out[#out + 1] = { name = name, label = job.label or name }
    end
    table.sort(out, function(a, b) return (a.label or a.name):lower() < (b.label or b.name):lower() end)
    return out
end

function AdminApi.OnlinePlayers()
    local out = {}
    local players = (ESX and ESX.GetExtendedPlayers) and ESX.GetExtendedPlayers() or {}
    for _, xPlayer in pairs(players) do
        local name = xPlayer.getName and xPlayer.getName() or xPlayer.name
        out[#out + 1] = {
            id = xPlayer.source,
            name = name or ('ID ' .. xPlayer.source),
            identifier = xPlayer.identifier,
            job = xPlayer.job and xPlayer.job.name or nil,
        }
    end
    table.sort(out, function(a, b) return a.id < b.id end)
    return out
end

function AdminApi.GaragesArray()
    local out = {}
    for _, def in pairs(Core.GetGarages()) do out[#out + 1] = def end
    table.sort(out, function(a, b) return a.id < b.id end)
    return out
end

function AdminApi.BuildBootstrap(src)
    return {
        locale = Config.Locale,
        perms = AdminPerms.GetPlayerPerms(src),
        permKeys = AdminPerms.PERMS,
        settings = AdminApi.SettingsPayload(),
        items = AdminApi.ItemsArray(),
        groups = AdminApi.GroupsArray(),
        suggestedGroups = AdminPerms.SUGGESTED_GROUPS,
        jobsList = AdminApi.JobsList(),
        onlinePlayers = AdminApi.OnlinePlayers(),
        vehicleTypes = AdminPerms.VEHICLE_TYPES,
        mskGarageRunning = Core.IsGarageRunning(),
        garages = AdminApi.GaragesArray(),
        scripts = {
            fuel = AdminPerms.FUEL_SCRIPTS,
            vehicleKeys = AdminPerms.VEHICLEKEY_SCRIPTS,
        },
    }
end

-- Push live settings (incl. theme/fuel/plate/keys) to all clients.
function AdminApi.Broadcast()
    TriggerClientEvent('msk_givevehicle:syncSettings', -1, { settings = AdminApi.SettingsPayload() })
end

local function ok(src) return { ok = true, data = AdminApi.BuildBootstrap(src) } end
local function fail(err) return { ok = false, err = err } end

----------------------------------------------------------------
-- Bootstrap
----------------------------------------------------------------
MSK.Register('msk_givevehicle:admin:bootstrap', function(src)
    if not AdminPerms.CanOpen(src) then return fail('no_permission') end
    return ok(src)
end)

----------------------------------------------------------------
-- Vehicle actions
----------------------------------------------------------------
-- Resolves/validates a chosen garage id (only when msk_garage runs).
local function resolveGarage(g)
    if g == nil or g == '' then return nil, true end
    if not Core.IsGarageRunning() then return nil, true end -- ignore stale selection
    if type(g) ~= 'string' or not Core.GetGarages()[g] then return nil, false end
    return g, true
end

MSK.Register('msk_givevehicle:admin:vehicle:give', function(src, data)
    if not AdminPerms.Has(src, 'vehicle.give') then return fail('no_permission') end
    if type(data) ~= 'table' then return fail('bad_input') end
    local target = tonumber(data.target)
    if not target then return fail('no_target') end
    local garage, gok = resolveGarage(data.garage)
    if not gok then return fail('unknown_garage') end

    return Core.Give({
        captureClient = src,
        targetId = target,
        type = oneOf(data.type, AdminPerms.VEHICLE_TYPES, 'car'),
        model = str(data.model, 60),
        plate = data.plate ~= nil and str(data.plate, 16) or nil,
        garage = garage,
        notifySrc = src,
    })
end)

MSK.Register('msk_givevehicle:admin:vehicle:givejob', function(src, data)
    if not AdminPerms.Has(src, 'vehicle.givejob') then return fail('no_permission') end
    if type(data) ~= 'table' then return fail('bad_input') end
    local target = tonumber(data.target)
    if not target then return fail('no_target') end
    local job = str(data.job, 50)
    if not job or #job == 0 then return fail('bad_job') end
    local garage, gok = resolveGarage(data.garage)
    if not gok then return fail('unknown_garage') end

    return Core.Give({
        captureClient = src,
        targetId = target,
        type = oneOf(data.type, AdminPerms.VEHICLE_TYPES, 'car'),
        model = str(data.model, 60),
        plate = data.plate ~= nil and str(data.plate, 16) or nil,
        garage = garage,
        job = job,
        bool = (data.owner == 'job') and '1' or '0',
        notifySrc = src,
    })
end)

MSK.Register('msk_givevehicle:admin:vehicle:spawn', function(src, data)
    if not AdminPerms.Has(src, 'vehicle.spawn') then return fail('no_permission') end
    if type(data) ~= 'table' then return fail('bad_input') end
    local target = tonumber(data.target)
    if not target then return fail('no_target') end
    local plate = str(data.plate, 16)
    if not plate or #plate == 0 then return fail('bad_plate') end
    return Core.Spawn({ targetId = target, plate = plate })
end)

MSK.Register('msk_givevehicle:admin:vehicle:delete', function(src, data)
    if not AdminPerms.Has(src, 'vehicle.delete') then return fail('no_permission') end
    if type(data) ~= 'table' then return fail('bad_input') end
    local plate = str(data.plate, 16)
    if not plate or #plate == 0 then return fail('bad_plate') end
    return Core.Delete({ plate = plate })
end)

MSK.Register('msk_givevehicle:admin:vehicle:move', function(src, data)
    if not AdminPerms.Has(src, 'vehicle.move') then return fail('no_permission') end
    if type(data) ~= 'table' then return fail('bad_input') end
    local plate = str(data.plate, 16)
    if not plate or #plate == 0 then return fail('bad_plate') end
    return Core.Move({ plate = plate, garage = str(data.garage, 60) })
end)

MSK.Register('msk_givevehicle:admin:vehicle:browse', function(src, data)
    if not AdminPerms.Has(src, 'vehicle.browse') then return fail('no_permission') end
    data = type(data) == 'table' and data or {}
    return Core.Browse({
        page = data.page,
        query = str(data.query, 60),
        garage = str(data.garage, 60),
        vtype = oneOf(data.vtype, AdminPerms.VEHICLE_TYPES, nil),
        model = str(data.model, 60),
    })
end)

----------------------------------------------------------------
-- Item vehicles
----------------------------------------------------------------
MSK.Register('msk_givevehicle:admin:items:save', function(src, data)
    if not AdminPerms.Has(src, 'items.manage') then return fail('no_permission') end
    local def, err = AdminApi.SanitizeItem(type(data) == 'table' and data.item or nil)
    if not def then return fail(err or 'bad_input') end

    MySQL.insert.await(
        'INSERT INTO `msk_givevehicle_items` (`id`, `label`, `data`, `enabled`) VALUES (?, ?, ?, 1) ' ..
        'ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `data` = VALUES(`data`)',
        { def.id, def.label, json.encode({ model = def.model, categorie = def.categorie, label = def.label }) }
    )
    AdminStore.LoadItems()
    Items.Register(def.id)
    return ok(src)
end)

MSK.Register('msk_givevehicle:admin:items:delete', function(src, data)
    if not AdminPerms.Has(src, 'items.manage') then return fail('no_permission') end
    local id = type(data) == 'table' and data.id or nil
    if type(id) ~= 'string' or not (Config.Vehicles or {})[id] then return fail('not_found') end

    MySQL.query.await('DELETE FROM `msk_givevehicle_items` WHERE `id` = ?', { id })
    AdminStore.LoadItems()
    return ok(src)
end)

----------------------------------------------------------------
-- Settings
----------------------------------------------------------------
MSK.Register('msk_givevehicle:admin:settings:save', function(src, data)
    if not AdminPerms.Has(src, 'settings.manage') then return fail('no_permission') end
    if type(data) ~= 'table' or type(data.settings) ~= 'table' then return fail('bad_input') end

    local clean = AdminApi.SanitizeSettings(data.settings)
    for k, v in pairs(clean) do
        MySQL.insert.await(
            'INSERT INTO `msk_givevehicle_settings` (`skey`, `svalue`) VALUES (?, ?) ' ..
            'ON DUPLICATE KEY UPDATE `svalue` = VALUES(`svalue`)',
            { k, json.encode(v) }
        )
    end

    local oldCmd = Config.adminCommand
    AdminStore.LoadSettings()
    if Config.adminCommand ~= oldCmd then AdminCommand.Register(Config.adminCommand) end
    AdminApi.Broadcast()
    return ok(src)
end)

----------------------------------------------------------------
-- Permissions
----------------------------------------------------------------
local function normGroup(name)
    if type(name) ~= 'string' then return nil end
    name = name:lower():gsub('^group%.', '')
    if not name:match(ID_PATTERN) then return nil end
    return name
end

MSK.Register('msk_givevehicle:admin:perms:saveGroup', function(src, data)
    if not AdminPerms.Has(src, 'permissions.manage') then return fail('no_permission') end
    local name = normGroup(type(data) == 'table' and data.name or nil)
    if not name then return fail('bad_name') end
    if AdminPerms.IsProtected(name) then return fail('protected') end
    if AdminPerms.IsBlacklisted(name) then return fail('blacklisted') end

    local matrix = {}
    local incoming = type(data) == 'table' and type(data.perms) == 'table' and data.perms or {}
    for _, key in ipairs(AdminPerms.PERMS) do
        matrix[key] = incoming[key] == true
    end

    MySQL.insert.await(
        'INSERT INTO `msk_givevehicle_permissions` (`group_name`, `perms`) VALUES (?, ?) ' ..
        'ON DUPLICATE KEY UPDATE `perms` = VALUES(`perms`)',
        { name, json.encode(matrix) }
    )
    AdminStore.LoadPermissions()
    AdminPerms.Invalidate()
    return ok(src)
end)

MSK.Register('msk_givevehicle:admin:perms:deleteGroup', function(src, data)
    if not AdminPerms.Has(src, 'permissions.manage') then return fail('no_permission') end
    local name = normGroup(type(data) == 'table' and data.name or nil)
    if not name then return fail('bad_name') end
    if AdminPerms.IsProtected(name) then return fail('protected') end

    MySQL.query.await('DELETE FROM `msk_givevehicle_permissions` WHERE `group_name` = ?', { name })
    AdminStore.LoadPermissions()
    AdminPerms.Invalidate()
    return ok(src)
end)

MSK.Register('msk_givevehicle:admin:perms:dashboardGroups', function(src, data)
    if not AdminPerms.Has(src, 'permissions.manage') then return fail('no_permission') end
    local list, seen = {}, {}
    if type(data) == 'table' and type(data.groups) == 'table' then
        for _, g in ipairs(data.groups) do
            local name = normGroup(g)
            if name and not AdminPerms.IsBlacklisted(name) and not AdminPerms.IsProtected(name) and not seen[name] then
                seen[name] = true
                list[#list + 1] = name
            end
        end
    end
    MySQL.insert.await(
        'INSERT INTO `msk_givevehicle_settings` (`skey`, `svalue`) VALUES (?, ?) ' ..
        'ON DUPLICATE KEY UPDATE `svalue` = VALUES(`svalue`)',
        { 'dashboardGroups', json.encode(list) }
    )
    AdminStore.LoadSettings()
    AdminPerms.Invalidate()
    return ok(src)
end)

MSK.Register('msk_givevehicle:admin:perms:validateGroup', function(src, data)
    if not AdminPerms.Has(src, 'permissions.manage') then return fail('no_permission') end
    local name = normGroup(type(data) == 'table' and data.name or nil)
    if not name then return { ok = true, valid = false } end
    if AdminPerms.IsBlacklisted(name) then return { ok = true, valid = false, blacklisted = true } end

    local found = false
    for _, pid in ipairs(GetPlayers()) do
        if AdminPerms.PlayerInGroup(tonumber(pid), name) then found = true; break end
    end
    return { ok = true, valid = true, exists = found }
end)
