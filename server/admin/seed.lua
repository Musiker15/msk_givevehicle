AdminSeed = AdminSeed or {}

local function isSeeded()
    local row = MySQL.single.await("SELECT `skey` FROM `msk_givevehicle_settings` WHERE `skey` = '__seeded__'")
    return row ~= nil
end

local function setSetting(key, value)
    MySQL.insert.await(
        'INSERT INTO `msk_givevehicle_settings` (`skey`, `svalue`) VALUES (?, ?) ' ..
        'ON DUPLICATE KEY UPDATE `svalue` = VALUES(`svalue`)',
        { key, json.encode(value) }
    )
end

----------------------------------------------------------------
-- One-time import of the static config into the DB.
----------------------------------------------------------------
function AdminSeed.Run(force)
    if not force and isSeeded() then return false end

    -- Settings (editable whitelist) + dashboardGroups.
    for _, key in ipairs(AdminPerms.SETTINGS_KEYS) do
        if Config[key] ~= nil then setSetting(key, Config[key]) end
    end
    setSetting('dashboardGroups', Config.dashboardGroups or {})

    -- Item vehicles.
    for id, def in pairs(Config.Vehicles or {}) do
        MySQL.insert.await(
            'INSERT INTO `msk_givevehicle_items` (`id`, `label`, `data`, `enabled`) VALUES (?, ?, ?, 1) ' ..
            'ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `data` = VALUES(`data`)',
            { id, def.label, json.encode({ model = def.model, categorie = def.categorie, label = def.label }) }
        )
    end

    -- Default permission groups: admin = all, mod = give + browse.
    MySQL.insert.await(
        'INSERT INTO `msk_givevehicle_permissions` (`group_name`, `perms`) VALUES (?, ?) ' ..
        'ON DUPLICATE KEY UPDATE `perms` = VALUES(`perms`)',
        { 'admin', json.encode(AdminPerms.AllPerms()) }
    )
    MySQL.insert.await(
        'INSERT INTO `msk_givevehicle_permissions` (`group_name`, `perms`) VALUES (?, ?) ' ..
        'ON DUPLICATE KEY UPDATE `perms` = VALUES(`perms`)',
        { 'mod', json.encode({ ['vehicle.give'] = true, ['vehicle.browse'] = true }) }
    )

    setSetting('__seeded__', os.time())

    print('^2[msk_givevehicle]^0 Admin seed complete (settings/items/permissions imported into DB).')
    return true
end
