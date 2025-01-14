-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
-- Put lazy into the runtime path
vim.opt.runtimepath:prepend(lazypath)

-- NOTE: Setup lazy nvim which is the package manager for your plugins

require('lazy').setup('plugins', {
  change_detection = {
    -- this option finally disables the annoying blocking notification
    -- https://github.com/folke/lazy.nvim/issues/32#issuecomment-1443733721
    notify = false,
  },
})
