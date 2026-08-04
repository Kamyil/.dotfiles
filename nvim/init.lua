-- Neovim configuration entrypoint. Each concern lives in lua/config/.
require('config.options')
require('config.plugins')
require('config.keymaps')
require('config.plugin_setup')
require('config.autocmds')
require('config.ui_lsp')
require('config.statusline')
require('config.commands')
require('config.colors')
-- Keep experiments opt-in so the stable configuration remains unchanged.
if vim.env.NVIM_EXPERIMENTS == '1' then
  require('config.experiments').setup()
end
