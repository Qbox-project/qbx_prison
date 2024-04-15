fx_version 'cerulean'
game 'gta5'

description 'qbx_prison'
repository 'https://github.com/Qbox-project/qbx_prison'
version '1.0.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
    'client/jobs.lua',
    'client/prisonbreak.lua'
}

server_script 'server/main.lua'

files {
    'locales/*.json',
    'config/shared.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
