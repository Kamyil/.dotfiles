--[[
    I hope you enjoy your Neovim journey,
    - TJ
    P.S. You can delete this when you're done too. It's your config now! :)

    Thanks TJ, highly appreciated this! 
    - Kamil
--]]

-- Load and configure Vim options
require('options')
-- Load keymaps/mappings
require('keymaps')
-- Load autocommands
require('autocommands')
-- Load lazy.nvim package manager (and before it - install if it's not installed into computer)
require('lazy_plugin_manager')

-- then if some plugins won't be installed, Lazy will automatically install it
-- if all are installed, then simply finish nvim startup

-- and finally polish the experience
require('overrides')
