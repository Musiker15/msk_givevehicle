fx_version 'cerulean'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_givevehicle'
description 'Give or Delete Vehicles with Command or Item'
version '2.0.3'

lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'@msk_core/import.lua',
	'config.lua',
	'translation.lua'
}

client_scripts {
	'client.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua',
	'versionchecker.lua'
}

dependencies {
	'es_extended',
	'oxmysql',
	'msk_core'
}