fx_version 'cerulean'
game 'gta5'

description 'Criminal Job Cooldowns for QB-Core'
author 'xThrasherrr'

shared_scripts { '@ox_lib/init.lua' }
client_scripts { 'client/*.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'configs/server.lua', 'server/*.lua' }

lua54 'yes'