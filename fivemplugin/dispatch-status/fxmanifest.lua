-- This file defines the resource for FiveM.
-- It tells FiveM what files to load and what metadata to use.

fx_version 'cerulean'
game 'gta5'

author 'David B. 440'
description 'Displays dispatch status based on a Discord bot command.'
version '1.0.0'

-- The server-side script that listens for the web request from the Discord bot.
server_script 'server.lua'

-- The client-side script that draws the text on every player's screen.
client_script 'client.lua'
