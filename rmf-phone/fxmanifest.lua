fx_version 'cerulean'
game 'gta5'

author 'RMF Development Team'
description 'RMF Phone - Android styled phone for FiveM'
version '1.0.0'

shared_scripts {
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/css/*.css',
    'ui/js/*.js',
    'ui/apps/**/*.html',
    'ui/apps/**/*.css',
    'ui/apps/**/*.js',
    'ui/assets/**/*',
    'ui/sounds/*.ogg'
}

dependencies {
    'mysql-async'
}

lua54 'yes'