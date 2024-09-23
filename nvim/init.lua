--[[
    I hope you enjoy your Neovim journey,
    - TJ
    P.S. You can delete this when you're done too. It's your config now! :)

    Thanks TJ, highly appreciated this! 
    - Kamil
--]]

-- Load Vim options
require 'options'
-- Load keymaps/mappings
require 'keymappings'
-- Load autocommands
require 'autocommands'

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

vim.opt.rtp:prepend(lazypath)

-- NOTE: Setup lazy nvim which is the package manager for your plugins
require('lazy').setup {
  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  { lazy = true, import = 'plugins' },
  --
}
