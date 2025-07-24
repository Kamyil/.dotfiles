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

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gl', vim.diagnostic.open_float, 'Open Diagnostic Float')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('gs', vim.lsp.buf.signature_help, 'Signature Documentation')
    map('gD', vim.lsp.buf.declaration, 'Goto Declaration')

    map('<leader>v', '<cmd>vsplit | lua vim.lsp.buf.definition()<cr>', 'Goto Definition in Vertical Split')

    local wk = require('which-key')
    wk.add({
      { '<leader>la', vim.lsp.buf.code_action, desc = 'Code Action' },
      { '<leader>lA', vim.lsp.buf.range_code_action, desc = 'Range Code Actions' },
      { '<leader>ls', vim.lsp.buf.signature_help, desc = 'Display Signature Information' },
      { '<leader>lr', vim.lsp.buf.rename, desc = 'Rename all references' },
      { '<leader>lf', vim.lsp.buf.format, desc = 'Format' },
      { '<leader>Wa', vim.lsp.buf.add_workspace_folder, desc = 'Workspace Add Folder' },
      { '<leader>Wr', vim.lsp.buf.remove_workspace_folder, desc = 'Workspace Remove Folder' },
      {
        '<leader>Wl',
        function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end,
        desc = 'Workspace List Folders',
      },
    })

    local function client_supports_method(client, method, bufnr)
      if vim.fn.has('nvim-0.11') == 1 then
        return client:supports_method(method, bufnr)
      else
        return client.supports_method(method, { bufnr = bufnr })
      end
    end

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event2.buf })
        end,
      })
    end

    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- go to last loc when opening a buffer
-- this mean that when you open a file, you will be at the last position
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
-- go to last loc when opening a buffer
-- this mean that when you open a file, you will be at the last position
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
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
set_autoformat({ 'html' }, false)
