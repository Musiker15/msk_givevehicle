Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.VersionChecker = true
Config.Debug = true
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
-- Look for type == 'client' and type == 'server'
Config.Notification = function(src, type, xPlayer, message) -- xPlayer = ESX.GetPlayerFromId(src)
    if type == 'client' then -- clientside
        ESX.ShowNotification(message) -- replace this with your Notify
    elseif type == 'server' then -- serverside
        xPlayer.showNotification(message) -- replace this with your Notify
    end
end
----------------------------------------------------------------
Config.MySQL = {
    type = 'type', -- Type Column
    stored = 'stored', -- Stored Column
}

Config.AdminGroups = {'superadmin', 'admin'} -- You can set multiple groups
-- Ingame Commands
Config.Command = 'giveveh' -- Read the Readme.md for Command Usage
Config.Command2 = 'delveh' -- Read the Readme.md for Command Usage
-- Console Commands
Config.ConsoleCommand = '_giveveh' -- Read the Readme.md for Command Usage
Config.ConsoleCommand2 = '_delveh' -- Read the Readme.md for Command Usage

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