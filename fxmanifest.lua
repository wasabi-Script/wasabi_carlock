fx_version 'cerulean'
game 'gta5'
author 'Wasabirobby'
--description 'github here'
version '1.1.1'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/main.js'
}


client_scripts {
    'client/**.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/**.lua'
}

shared_script 'config.lua'

lua54 'yes'

escrow_ignore {
    'config.lua'
  }