-- Admin dashboard boot: create tables, seed once, load DB into Config, register
-- usable items + the command. Runs LAST so all of the above is available.

local function createTables()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `msk_givevehicle_settings` (
            `skey` varchar(80) NOT NULL,
            `svalue` longtext DEFAULT NULL,
            PRIMARY KEY (`skey`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `msk_givevehicle_permissions` (
            `group_name` varchar(80) NOT NULL,
            `perms` longtext DEFAULT NULL,
            PRIMARY KEY (`group_name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `msk_givevehicle_items` (
            `id` varchar(60) NOT NULL,
            `label` varchar(120) DEFAULT NULL,
            `data` longtext NOT NULL,
            `enabled` tinyint(1) NOT NULL DEFAULT 1,
            `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    createTables()
    AdminSeed.Run(false)
    AdminStore.LoadAll()
    Items.RegisterAll()
    AdminCommand.Register(Config.adminCommand)

    -- Push freshly loaded settings to anyone already connected (live restart).
    AdminApi.Broadcast()

    print(('^2[msk_givevehicle]^0 Admin dashboard ready — command: ^5/%s^0'):format(Config.adminCommand or 'givevehadmin'))
end)
