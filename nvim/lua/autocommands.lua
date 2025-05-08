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

-- Disable Tree-sitter for buffers larger than MAX_FILESIZE in order to not lag the Neovim
vim.api.nvim_create_autocmd('BufReadPre', {
  pattern = '*',
  callback = function()
    local MAX_FILESIZE = 1000000 -- 1MB
    local filepath = vim.fn.expand('<afile>')
    local ok, stats = pcall(vim.loop.fs_stat, filepath)

    if ok and stats and stats.size > MAX_FILESIZE then
      -- Temporarily disable Tree-sitter and syntax highlighting
      vim.cmd('TSBufDisable highlight')
      vim.cmd('syntax off')
    end
  end,
})

-- Open file at the last position it was edited earlier
-- vim.api.nvim_create_autocmd('BufReadPost', {
--   desc = 'Open file at the last position it was edited earlier',
--   group = misc_augroup,
--   pattern = '*',
--   command = 'silent! normal! g`"zv',
-- })

-- -- reload config file on change
-- vim.api.nvim_create_autocmd('BufWritePost', {
--   group = 'bufcheck',
--   pattern = vim.env.MYVIMRC,
--   command = 'silent source %',
-- })

--
-- Autoformat setting
local set_autoformat = function(pattern, bool_val)
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = pattern,
    callback = function()
      vim.b.autoformat = bool_val
    end,
  })
end

set_autoformat({ 'lua' }, true)
set_autoformat({ 'svelte' }, false)
set_autoformat({ 'js' }, false)
set_autoformat({ 'ts' }, false)
