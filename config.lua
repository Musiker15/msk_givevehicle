Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.Debug = true
Config.VersionChecker = true
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message, typ) 
    if IsDuplicityVersion() then -- serverside
        MSK.Notification(source, 'GiveVehicle', message, typ, 5000)
    else -- clientside
        MSK.Notification('GiveVehicle', message, typ, 5000)
    end
end
----------------------------------------------------------------
Config.AdminGroups = {'superadmin', 'admin'} -- You can set multiple groups

Config.Commands = {
    giveveh = 'giveveh', -- Read the Readme.md for Command Usage
    delveh = 'delveh', -- Read the Readme.md for Command Usage
    givejobveh = 'givejobveh', -- Read the Readme.md for Command Usage
    spawnveh = 'spawnveh', -- Read the Readme.md for Command Usage // You can use this at the console too
}

Config.ConsoleCommands = {
    giveveh = '_giveveh',
    delveh = '_delveh',
    givejobveh = '_givejobveh',
}
----------------------------------------------------------------
Config.FuelSystem = function(vehicle, fuel) -- Only for Command4: spawnveh
    -- exports['LegacyFuel']:SetFuel(vehicle, fuel) -- LegacyFuel
    -- exports['myFuel']:SetFuel(vehicle, fuel) -- myFuel
    -- SetVehicleFuelLevel(vehicle, fuel + 0.0) -- FiveM Native
    -- exports['qs-fuelstations']:SetFuel(vehicle, fuel) -- Quasar Fuelstations
    Entity(vehicle).state.fuel = fuel -- ox_fuel and msk_fuel
end

Config.Plate = {
    format = 'XXX XXX', -- 'XXX XXX' or 'XX XXXX'
    
    enablePrefix = true, -- Set to false if you want Random Letters
    prefix = 'PX' -- Only if format = 'XX XXXX' // Looks like 'PX 1234'
}
----------------------------------------------------------------
-- You can give Player an Item and they can use the Item to get a Vehicle
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