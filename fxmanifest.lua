fx_version 'adamant'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
author 'Darky_13'
description 'Texas Hold\'em Poker Script for RedM using VORP'
version '0.0.1'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server.lua',
}

client_scripts {
	'@vorp_core/client/dataview.lua',	
    'client.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
	'html/app.js',
	'html/style.css',
}

dependencies {

}
