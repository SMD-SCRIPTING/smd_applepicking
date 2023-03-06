fx_version "bodacious"

game "gta5"

ui_page {
	'html/index.html'
}

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

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js',

    'html/css/bootstrap.min.css',
    'html/js/jquery.min.js',
}
