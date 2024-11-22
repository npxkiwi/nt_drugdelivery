fx_version 'cerulean'

game 'gta5'

lua54 'yes'

author 'Notepad'

shared_scripts {
    '@ox_lib/init.lua',
    'Config.lua',
}


client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
 
