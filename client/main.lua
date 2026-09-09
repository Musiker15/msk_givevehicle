-- Client vehicle logic: spawn owned vehicles, and capture properties for the
-- dashboard/console give flow (reading properties off a vehicle is client-only).

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end

----------------------------------------------------------------
-- Vehicle properties
--
-- The FORMAT has to match the framework, not our own taste: these properties
-- end up in the framework's vehicle table, and the garage scripts read them
-- back from there. ESX writes and expects its own layout, QBCore and Qbox use
-- the ox_lib one. Handing an ox_lib table to an ESX garage produces a vehicle
-- without mods, wrong colours, or no vehicle at all.
--
-- ESX is fetched lazily instead of through @es_extended/imports.lua, so that
-- this resource no longer refuses to start on a server without ESX.
----------------------------------------------------------------
local esxCache

local function esx()
    if esxCache ~= nil then return esxCache or nil end

    local ok, core = pcall(function() return exports['es_extended']:getSharedObject() end)
    esxCache = (ok and core) or false

    return esxCache or nil
end

local function isEsx()
    return MSK.Bridge.Framework.Type == 'ESX' and esx() ~= nil
end

local function getVehicleProperties(vehicle)
    if isEsx() then
        return esx().Game.GetVehicleProperties(vehicle)
    end

    return lib.getVehicleProperties(vehicle)
end

local function setVehicleProperties(vehicle, props)
    if isEsx() then
        return esx().Game.SetVehicleProperties(vehicle, props)
    end

    return lib.setVehicleProperties(vehicle, props)
end

local function deleteVehicle(vehicle)
    if isEsx() then
        return esx().Game.DeleteVehicle(vehicle)
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)

    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
end

-- Spawns a vehicle and hands the handle to the callback, like ESX.Game
-- SpawnVehicle did. On anything but ESX this is the ox_lib route.
local function spawnVehicle(model, coords, heading, callback)
    if isEsx() then
        return esx().Game.SpawnVehicle(model, coords, heading, callback)
    end

    local hash = type(model) == 'number' and model or joaat(model)

    if not lib.requestModel(hash, 10000) then
        logging('error', ('Could not load vehicle model %s'):format(tostring(model)))
        return callback(0)
    end

    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading or 0.0, true, false)

    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(vehicle), true)
    SetModelAsNoLongerNeeded(hash)

    callback(vehicle)
end

-- Applies fuel using the selected fuel system (DB-managed, synced live).
local function applyFuel(vehicle, fuel)
    fuel = fuel or 100.0
    local sys = Config.FuelSystem or 'statebag'
    if sys == 'LegacyFuel' then
        exports['LegacyFuel']:SetFuel(vehicle, fuel)
    elseif sys == 'qs-fuelstations' then
        exports['qs-fuelstations']:SetFuel(vehicle, fuel)
    elseif sys == 'native' then
        SetVehicleFuelLevel(vehicle, fuel + 0.0)
    elseif sys == 'custom' then
        if type(Config.CustomFuelSystem) == 'function' then Config.CustomFuelSystem(vehicle, fuel) end
    else -- 'statebag' / 'ox_fuel' / 'msk_fuel'
        Entity(vehicle).state.fuel = fuel
    end
end

-- Spawn an owned vehicle from stored properties (used by the spawn action).
RegisterNetEvent('msk_givevehicle:spawnVehicle', function(props)
    local playerPed = PlayerPedId()

    spawnVehicle(props.model, GetEntityCoords(playerPed), GetEntityHeading(playerPed), function(vehicle)
        setVehicleProperties(vehicle, props)
        applyFuel(vehicle, props.fuelLevel)

        if Config.VehicleKeys and Config.VehicleKeys.enable
            and Config.VehicleKeys.script == 'msk_vehiclekeys'
            and GetResourceState('msk_vehiclekeys') == 'started' then
            if not exports.msk_vehiclekeys:HasPlayerKey(vehicle) then
                exports.msk_vehiclekeys:AddTempKey(vehicle)
            end
        end
    end)
end)

-- Capture properties for a give request, then hand them back to the server.
-- The plate is already validated & locked server-side.
RegisterNetEvent('msk_givevehicle:admin:capture', function(req)
    if type(req) ~= 'table' or not req.requestId then return end
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    spawnVehicle(req.model, coords, 0.0, function(vehicle)
        if not DoesEntityExist(vehicle) then
            TriggerServerEvent('msk_givevehicle:admin:captureFailed', req.requestId, req.model)
            return
        end
        SetEntityVisible(vehicle, false, false)
        SetEntityCollision(vehicle, false, false)

        local props = getVehicleProperties(vehicle)
        props.plate = req.plate
        props.fuelLevel = 100.0

        TriggerServerEvent('msk_givevehicle:admin:captured', req.requestId, props)
        deleteVehicle(vehicle)
    end)
end)
