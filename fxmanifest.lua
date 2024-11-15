fx_version 'cerulean'
game 'gta5'

author "PEEVEE"
description "discord.gg/jRgkb5sM3w"

shared_script '@ox_lib/init.lua'

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'server/server.lua'
}

client_script "client/client.lua"

files {
    "config.lua",
    "locales/*.json",
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
