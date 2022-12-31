fx_version "bodacious"

game "gta5"

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'server/main.lua',
	'config.lua',
}

client_scripts {
	'@es_extended/locale.lua',
	'client/main.lua',
	'config.lua',
}