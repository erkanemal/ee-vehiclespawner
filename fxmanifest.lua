fx_version 'adamant'
games { 'gta5' }

version '1.0'

lua54 'yes'



author 'erkanpl'
description 'Donater Car based on OX_Lib'
version '1.0'
scriptname 'ee-dono_veh'

shared_script '@ox_lib/init.lua'


client_scripts {
    '@menuv/menuv.lua',
    'config.lua',
    'client/**.lua',
}

server_scripts {
    'config.lua',
}

