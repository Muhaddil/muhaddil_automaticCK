fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Muhaddil'
description 'Automatic CK for inactive players'
version 'v1.0.0'

shared_script 'config.lua'

server_script {
    '@mysql-async/lib/MySQL.lua',
    'server/*'
}

shared_script '@ox_lib/init.lua'