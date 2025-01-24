fx_version 'cerulean'
game 'gta5'

author 'Fusion scripts. Yvoow2'
description 'Fusion scripts food delivery sidejob with levelling system.'
version '1.0.0'
lua54 'yes'

client_scripts {
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
}

files {
    'locales/*.json'
}

shared_script '@es_extended/locale.lua'
shared_script '@es_extended/imports.lua'
shared_script 'config.lua'
shared_script '@ox_lib/init.lua'
server_script '@oxmysql/lib/MySQL.lua'

dependencies {
    'es_extended',
    'ox_target',
}