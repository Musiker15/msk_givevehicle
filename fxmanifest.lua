fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_givevehicle'
description 'Give or Delete Vehicles with Command or Item'
version '1.5'

shared_scripts {
	'config.lua',
	'translation.lua'
}

client_scripts {
	'client.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}

dependencies {
	'es_extended',
	'oxmysql'
}