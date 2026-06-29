-- Client vehicle logic: spawn owned vehicles, and capture properties for the
-- dashboard/console give flow (ESX.Game.GetVehicleProperties is client-only).

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
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

    ESX.Game.SpawnVehicle(props.model, GetEntityCoords(playerPed), GetEntityHeading(playerPed), function(vehicle)
        ESX.Game.SetVehicleProperties(vehicle, props)
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

    ESX.Game.SpawnVehicle(req.model, coords, 0.0, function(vehicle)
        if not DoesEntityExist(vehicle) then
            TriggerServerEvent('msk_givevehicle:admin:captureFailed', req.requestId, req.model)
            return
        end
        SetEntityVisible(vehicle, false, false)
        SetEntityCollision(vehicle, false, false)

        local props = ESX.Game.GetVehicleProperties(vehicle)
        props.plate = req.plate
        props.fuelLevel = 100.0

        TriggerServerEvent('msk_givevehicle:admin:captured', req.requestId, props)
        ESX.Game.DeleteVehicle(vehicle)
    end)
end)
