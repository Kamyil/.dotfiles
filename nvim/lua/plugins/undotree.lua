return {
  'jiaoshijie/undotree',
  enabled = true,
  dependencies = 'nvim-lua/plenary.nvim',
  config = true,
  keys = { -- load the plugin only when using it's keybinding:
    { '<leader>U', "<cmd>lua require('undotree').toggle()<cr>" },
  },
}
