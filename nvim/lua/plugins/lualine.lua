return {
  'nvim-lualine/lualine.nvim',
  enabled = true,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = function()
    local harpoon_files = require('harpoon_files')

    return {
      icons_enabled = true,
      -- theme = 'catppuccin',
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      always_show_tabline = true,
      globalstatus = false,
      refresh = {
        statusline = 100,
        tabline = 100,
        winbar = 100,
      },

      sections = {
        lualine_c = {
          { harpoon_files.lualine_component },
        },
      },
    }
  end,
}
