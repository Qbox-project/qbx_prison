fx_version 'cerulean'
game 'gta5'

shared_scripts {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua',
    'client/jobs.lua',
    'client/prisonbreak.lua'
}

server_script 'server/main.lua'

lua54 'yes'