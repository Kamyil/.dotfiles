-- Status line
return {
  'nvim-lualine/lualine.nvim',
  enabled = true,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = function()
    local harpoon_files = require('harpoon_files')

    return {
      icons_enabled = true,
      theme = 'kanagawa',
      component_separators = { left = '|', right = '|' },
      section_separators = { left = '|', right = '|' },
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      -- always_divide_middle = true,
      always_show_tabline = false,
      globalstatus = false,

      refresh = {
        statusline = 100,
        tabline = 100,
        winbar = 100,
      },

      -- sections = {
      -- lualine_a = {},
      -- lualine_b = {},
      -- lualine_c = {},
      -- lualine_x = {},
      -- lualine_y = {},
      -- lualine_z = {
      --   { harpoon_files.lualine_component },
      -- },
      -- },
    }
  end,
}
