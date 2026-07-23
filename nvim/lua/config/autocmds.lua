-- Set global window border (after colorscheme loads)
vim.opt.winborder = 'rounded'

-- Autocommands
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
--
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Jump to last cursor position when opening a file',
  group = vim.api.nvim_create_augroup('last-cursor-position', { clear = true }),
  callback = function()
    if vim.fn.line('\'"') > 0 then
      vim.cmd('normal! g`"')
    end
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Open Fyler on startup when no file is provided',
  group = vim.api.nvim_create_augroup('fyler-startup', { clear = true }),
  callback = function()
    if #vim.api.nvim_list_uis() == 0 then
      return
    end

    local argc = vim.fn.argc()
    if argc > 1 then
      return
    end

    if argc == 1 then
      local arg0 = vim.fn.argv(0)
      if vim.fn.isdirectory(arg0) == 0 then
        return
      end
    end

    vim.schedule(function()
      if argc == 1 then
        local root_path = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.argv(0), ':p'))
        require('fyler').open({
          root_path = root_path,
          ui = {
            hidden_items = {
              always_visible = { '^' .. vim.pesc(root_path) .. '$' },
            },
          },
        })
      else
        require('fyler').open()
      end
    end)
  end,
})

-- Set the commentstring for Smarty templates
local smarty_augroup = vim.api.nvim_create_augroup('SmartyComment', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Set commentstring for Smarty templates',
  group = smarty_augroup,
  pattern = 'smarty',
  callback = function()
    vim.bo.commentstring = '{* %s *}'
  end,
})

-- Enhanced indentation detection
local indent_augroup = vim.api.nvim_create_augroup('IndentDetection', { clear = true })
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  desc = 'Detect and apply indentation settings',
  group = indent_augroup,
  pattern = '*',
  callback = function()
    -- Let vim-sleuth handle detection first
    vim.schedule(function()
      -- Force refresh indentation display
      if vim.bo.expandtab then
        -- Using spaces
        vim.opt_local.listchars:append({ tab = '→ ', lead = '·', trail = '·' })
      else
        -- Using tabs
        vim.opt_local.listchars:append({ tab = '→ ', trail = '·' })
      end

      -- Ensure proper tab display
      vim.opt_local.tabstop = vim.bo.tabstop
      vim.opt_local.shiftwidth = vim.bo.shiftwidth
      vim.opt_local.softtabstop = vim.bo.softtabstop
    end)
  end,
})

require('comfy-line-numbers').setup({
  down_key = 'j',
  up_key = 'k',

  -- Line numbers will be completely hidden for the following file/buffer types
  hidden_file_types = { 'help', 'TelescopePrompt', 'undotree' },
  hidden_buffer_types = { 'terminal', 'nofile' },
})
require('todo-comments').setup()
require('nvim-highlight-colors').setup({})
local wk = require('which-key')
wk.setup({
  preset = 'helix',
  win = {
    -- border = borders,
  },
})
wk.add({
  { '<leader>a', group = 'AI', icon = '󰧑' },
  { '<leader>aa', icon = '󰭻' },
  { '<leader>as', icon = '󰒅' },
  { '<leader>a+', icon = '󰐕' },
  { '<leader>at', icon = '󰔡' },
  { '<leader>ac', icon = '󰘳' },
  { '<leader>an', icon = '󰎔' },
  { '<leader>ai', icon = '󰜺' },
  { '<leader>aA', icon = '󰑐' },

  { '<leader>d', group = 'Database', icon = '' },
  { '<leader>db', icon = '' },
  { '<leader>dB', icon = '' },
  { '<leader>da', icon = '' },
  { '<leader>df', icon = '󰈞' },
  { '<leader>dr', icon = '󰑐' },

  { '<leader>f', group = 'Find', icon = '󰍉' },
  { '<leader>ff', icon = '󰈞' },
  { '<leader>fw', icon = '󰈬' },
  { '<leader>fk', icon = '󰌌' },

  { '<leader>g', group = 'Git', icon = '󰊢' },
  { '<leader>gg', icon = '󰊢' },
  { '<leader>gd', icon = '󰊢' },
  { '<leader>gb', icon = '󰜘' },
  { '<leader>gc', group = 'Conflict', icon = '󰞇' },
  { '<leader>gcc', icon = '󰄬' },
  { '<leader>gci', icon = '󰏫' },
  { '<leader>gcb', icon = '󰐙' },
  { '<leader>gcn', icon = '󰜺' },
  { '<leader>gc[', icon = '󰒮' },
  { '<leader>gc]', icon = '󰒭' },

  { '<leader>l', group = 'LSP', icon = '󰒋' },
  { '<leader>la', icon = '󰌵' },
  { '<leader>lf', icon = '󰉢' },
  { '<leader>lr', icon = '󰑕' },
  { '<leader>ld', icon = '󰈮' },
  { '<leader>lD', icon = '󰈇' },

  { '<leader>n', group = 'Notes', icon = '󰠮' },
  { '<leader>ni', icon = '󰻃' },
  { '<leader>nw', icon = '󰨲' },
  { '<leader>np', icon = '󰒮' },
  { '<leader>nf', icon = '󰈞' },
  { '<leader>ns', icon = '󰍉' },
  { '<leader>nc', icon = '󰄀' },
  { '<leader>na', icon = '󰃭' },
  { '<leader>nt', group = 'Todo/Time', icon = '󰄲' },
  { '<leader>ntt', icon = '󰐕' },
  { '<leader>ntx', icon = '󰄬' },
  { '<leader>ntp', icon = '󰦖' },
  { '<leader>nts', icon = '󱎫' },
  { '<leader>nte', icon = '󱎬' },

  { '<leader>r', group = 'Refactor', icon = '󰑌' },
  { '<leader>rr', icon = '󰑌' },

  { '<leader>u', icon = '󰄬' },

  { '<leader>w', icon = '󰆓' },
  { '<leader>q', icon = '󰈆' },
  { '<leader>D', icon = '󰨮' },
  { '<leader>/', icon = '󰤼' },
  { '<leader>-', icon = '󰤻' },
})
