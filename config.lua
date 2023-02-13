Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.VersionChecker = true
Config.Debug = true
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, xPlayer, message) 
    if IsDuplicityVersion() then -- serverside
        xPlayer.showNotification(message)
    else -- clientside
        ESX.ShowNotification(message)
    end
end
----------------------------------------------------------------
Config.AdminGroups = {'superadmin', 'admin'} -- You can set multiple groups

-- Ingame Commands
Config.Command = 'giveveh' -- Read the Readme.md for Command Usage
Config.Command2 = 'delveh' -- Read the Readme.md for Command Usage
Config.Command3 = 'givejobveh' -- Read the Readme.md for Command Usage

-- Console Commands
Config.ConsoleCommand = '_giveveh' -- Read the Readme.md for Command Usage
Config.ConsoleCommand2 = '_delveh' -- Read the Readme.md for Command Usage
Config.ConsoleCommand3 = '_givejobveh' -- Read the Readme.md for Command Usage
----------------------------------------------------------------
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