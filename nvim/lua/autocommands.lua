-- Contains nvim autocommands (commands that run automatically on nvim open). Helpful for doing some things on startup

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
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

-- Disable netrw completely
vim.api.nvim_create_autocmd('BufNewFile', {
  group = vim.api.nvim_create_augroup('RemoteFile', { clear = true }),
  callback = function()
    local f = vim.fn.expand('%:p')
    for _, v in ipairs({ 'sftp', 'scp', 'ssh', 'dav', 'fetch', 'ftp', 'http', 'rcp', 'rsync' }) do
      local p = v .. '://'
      if string.sub(f, 1, #p) == p then
        vim.cmd([[
          unlet g:loaded_netrw
          unlet g:loaded_netrwPlugin
          runtime! plugin/netrwPlugin.vim
          silent Explore %
        ]])
        vim.api.nvim_clear_autocmds({ group = 'RemoteFile' })
        break
      end
    end
  end,
})
