fx_version 'cerulean'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_givevehicle'
description 'Give, Spawn, Delete & Manage Vehicles via an in-game Admin Dashboard'
version '3.1.0'
license 'LGPL-3.0-or-later'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@msk_core/import.lua',
    'config.lua',
    'translation.lua',
    'shared/admin_perms.lua',
}

client_scripts {
    'client/main.lua',

    -- Admin dashboard
    'client/admin/main.lua',
    'client/admin/nui.lua',
    'client/admin/sync.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',

    'server/main.lua',
    'server/items.lua',
    'server/commands.lua',

    -- Vehicle-key adapters (init first, then the adapters register themselves)
    'server/keys/init.lua',
    'server/keys/msk_vehiclekeys.lua',
    'server/keys/VehicleKeyChain.lua',
    'server/keys/vehicles_keys.lua',

    'server/versionchecker.lua',

    -- Admin dashboard (boot.lua must stay LAST: it depends on all of the above)
    'server/admin/store.lua',
    'server/admin/permissions.lua',
    'server/admin/seed.lua',
    'server/admin/api.lua',
    'server/admin/command.lua',
    'server/admin/boot.lua',
}

ui_page 'html/index.html'

files {
    'html/**/*.*',
}

dependencies {
    'es_extended',
    'oxmysql',
    'msk_core',
}
