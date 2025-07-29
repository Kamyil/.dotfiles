return {
  {
    'stevearc/oil.nvim',
    enabled = true,
    lazy = true,
    cmd = 'Oil',
    keys = {
      -- { '<D-o>', '<cmd>Oil<CR>', silent = true, desc = 'Open Oil' },
      { '<leader>e', '<cmd>Oil<CR>', silent = true, desc = 'Open Oil' },
    },
    opts = {
      keymaps = {
        ['<D-i>'] = 'actions.select',
        ['yp'] = {
          desc = 'Copy filepath to system clipboard',
          callback = function()
            require('oil.actions').copy_entry_path.callback()
            vim.fn.setreg('+', vim.fn.getreg(vim.v.register))
            vim.notify('Copied full path', 'info', { title = 'Oil' })
          end,
        },
      },
      default_file_explorer = true,
      delete_to_trash = true,
      lsp_file_methods = {
        autosave_changes = true,
      },
    },
  },

  {
    'benomahony/oil-git.nvim',
    dependencies = { 'stevearc/oil.nvim' },
    -- No opts or config needed! Works automatically
  },
}
