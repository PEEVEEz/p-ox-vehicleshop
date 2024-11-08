fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

author "PEEVEE"

shared_script '@ox_lib/init.lua'
server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'server/server.lua'
}
client_script "client/client.lua"

files {
    "config.lua"
}
