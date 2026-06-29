Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.Debug = true
Config.VersionChecker = true
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!  (code hook, not DB-managed)
Config.Notification = function(source, message, typ)
    if IsDuplicityVersion() then -- serverside
        MSK.Notification(source, 'GiveVehicle', message, typ, 5000)
    else -- clientside
        MSK.Notification('GiveVehicle', message, typ, 5000)
    end
end
----------------------------------------------------------------
-- The in-game dashboard is opened with this command. DB-managed: editable in the
-- Settings tab. Access is gated by Config.dashboardGroups + the permission system
-- (group.admin always; group.user never) — NOT by this command being ACE-locked.
Config.adminCommand = 'adgiveveh'

-- Groups (besides the always-allowed group.admin) that may open the dashboard.
-- Permission-managed: edit in the Permissions tab. group.user is hard-blocked.
Config.dashboardGroups = { 'mod' }
----------------------------------------------------------------
-- Fuel system selector (DB-managed). One of:
--   'statebag'        -> Entity(vehicle).state.fuel  (ox_fuel & msk_fuel)
--   'LegacyFuel'      -> exports['LegacyFuel']:SetFuel
--   'ox_fuel'         -> Entity(vehicle).state.fuel
--   'qs-fuelstations' -> exports['qs-fuelstations']:SetFuel
--   'native'          -> SetVehicleFuelLevel
--   'custom'          -> calls Config.CustomFuelSystem below
Config.FuelSystem = 'statebag'

-- Only used when Config.FuelSystem == 'custom' (code hook, not DB-managed).
Config.CustomFuelSystem = function(vehicle, fuel)
    -- exports['myFuel']:SetFuel(vehicle, fuel)
    Entity(vehicle).state.fuel = fuel
end

Config.Plate = {
    format = 'XXX XXX', -- 'XXX XXX' or 'XX XXXX'

    enablePrefix = true, -- Set to false if you want Random Letters
    prefix = 'PX' -- Only if format = 'XX XXXX' // Looks like 'PX 1234'
}
----------------------------------------------------------------
-- Vehicle-key integration (DB-managed). When `enable` is on, keys are
-- automatically GIVEN to the player on give/spawn and REMOVED on delete, using
-- the selected (and started) key script. Auto-detected at runtime via
-- GetResourceState — if `script` isn't started, key ops are skipped silently.
Config.VehicleKeys = {
    enable = true,
    script = 'msk_vehiclekeys', -- 'msk_vehiclekeys' | 'VehicleKeyChain' | 'vehicles_keys'
}
----------------------------------------------------------------
-- Server-console commands stay available (the in-game slash commands were
-- replaced by the dashboard). These are the console command names.
Config.ConsoleCommands = {
    giveveh = '_giveveh',
    delveh = '_delveh',
    givejobveh = '_givejobveh',
    spawnveh = 'spawnveh', -- usable in the server console
}
----------------------------------------------------------------
-- Item vehicles (SEED for the dashboard's "Item Vehicles" tab). After the first
-- start these live in msk_givevehicle_items and are managed via the dashboard.
-- Players can use the item to get the vehicle delivered to a garage.
Config.Vehicles = {
    ["zentorno"] = { -- Item Name
        label = 'Zentorno',
        model = 'zentorno', -- Vehicle Name
        categorie = 'car' -- Vehicle Categorie
    },
    ["seashark"] = { -- Item Name
        label = 'Seashark',
        model = 'seashark', -- Vehicle Name
        categorie = 'boat' -- Vehicle Categorie
    },
}
