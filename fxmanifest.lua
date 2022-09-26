fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_vehicleItems'
description 'Give or Delete Vehicles with Command or Item'
version '1.0'

lua54 'yes'

escrow_ignore {
	'config.lua',
}

shared_scripts {
	'config.lua',
	'translation.lua'
}

client_scripts {
	'client.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server.lua'
}