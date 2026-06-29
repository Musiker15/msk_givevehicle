-- Vehicle-key adapter dispatcher. The active script is auto-detected at runtime:
-- it must be enabled in settings (Config.VehicleKeys.enable), selected
-- (Config.VehicleKeys.script) AND actually started (GetResourceState). If any of
-- these is false, key operations are skipped silently (no error).
Keys = Keys or {}

local adapters = {}

function Keys.RegisterAdapter(name, adapter)
    adapters[name] = adapter
end

local function current()
    if type(Config.VehicleKeys) ~= 'table' or not Config.VehicleKeys.enable then return nil end
    local name = Config.VehicleKeys.script
    local adapter = adapters[name]
    if not adapter then return nil end
    if GetResourceState(name) ~= 'started' then return nil end
    return adapter
end

-- Gives the player a (primary) key for the plate/model.
--   owner = { source = src } OR { identifier = '...' }
function Keys.GiveKey(owner, plate, model)
    local adapter = current()
    if not adapter or type(adapter.GiveKey) ~= 'function' then return false end
    local ok, err = pcall(adapter.GiveKey, owner, plate, model)
    if not ok then
        if Config.Debug then MSK.Logging('error', 'Keys.GiveKey adapter error:', tostring(err)) end
        return false
    end
    return true
end

-- Removes every key for the plate (used on delete).
function Keys.RemoveKey(plate)
    local adapter = current()
    if not adapter or type(adapter.RemoveKey) ~= 'function' then return false end
    local ok, err = pcall(adapter.RemoveKey, plate)
    if not ok then
        if Config.Debug then MSK.Logging('error', 'Keys.RemoveKey adapter error:', tostring(err)) end
        return false
    end
    return true
end

-- Whether a vehicle entity is already keyed for the holder (client-driven scripts).
function Keys.HasKey(vehicle)
    local adapter = current()
    if not adapter or type(adapter.HasKey) ~= 'function' then return false end
    local ok, result = pcall(adapter.HasKey, vehicle)
    if not ok then return false end
    return result == true
end

-- Is a key script currently active? (used to add a temp key on spawn, etc.)
function Keys.Active()
    return current() ~= nil
end
