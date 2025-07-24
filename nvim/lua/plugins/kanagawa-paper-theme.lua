return {
  'sho-87/kanagawa-paper.nvim',
  enabled = true,
  lazy = false,
  priority = 1000,
  opts = {
    -- enable undercurls for underlined text
    undercurl = true,
    -- transparent background
    transparent = true,
    -- highlight background for the left gutter
    gutter = true,
    -- background for diagnostic virtual text
    diag_background = true,
    -- dim inactive windows. Disabled when transparent
    dim_inactive = false,
    -- set colors for terminal buffers
    terminal_colors = true,
    -- cache highlights and colors for faster startup.
    -- see Cache section for more details.
    cache = true,

    styles = {
      -- style for comments
      comment = { italic = false, bold = false },
      -- style for functions
      functions = { italic = false, bold = false },
      -- style for keywords
      keyword = { italic = false, bold = false },
      -- style for statements
      statement = { italic = false, bold = false },
      -- style for types
      type = { italic = false, bold = false },
    },
    -- override default palette and theme colors
    colors = {
      palette = {},
      theme = {
        ink = {},
        canvas = {},
      },
    },
    -- adjust overall color balance for each theme [-1, 1]
    color_offset = {
      ink = { brightness = 0, saturation = 0 },
      canvas = { brightness = 0, saturation = 0 },
    },
    -- override highlight groups
    -- overrides = function()
    --   local colors = require('kanagawa.colors').setup()
    --   local palette_colors = colors.palette
    --   local theme_colors = colors.theme
    --   return {
    --     ['@tag.svelte'] = { fg = '#2D4F67', bold = true },
    --   }
    -- end,

    -- uses lazy.nvim, if installed, to automatically enable needed plugins
    auto_plugins = true,
    -- enable highlights for all plugins (disabled if using lazy.nvim)
    all_plugins = package.loaded.lazy == nil,
    -- manually enable/disable individual plugins.
    -- check the `groups/plugins` directory for the exact names
    plugins = {
      -- examples:
      -- rainbow_delimiters = true
      -- which_key = false
    },

    -- enable integrations with other applications
    integrations = {
      -- automatically set wezterm theme to match the current neovim theme
      wezterm = {
        enabled = true,
        -- neovim will write the theme name to this file
        -- wezterm will read from this file to know which theme to use
        path = (os.getenv('TEMP') or '/tmp') .. '/nvim-theme',
      },
    },
  },
  config = function(_, opts)
    -- make sure true color is on
    vim.opt.termguicolors = true
    vim.opt.background = 'dark'

    -- 1) setup + colorscheme
    require('kanagawa-paper').setup(opts)

    -- 2) schedule your two TS overrides for the next event loop
    vim.schedule(function()
      vim.api.nvim_set_hl(0, '@tag.svelte', { fg = '#8EA4A2', bold = false })
      vim.api.nvim_set_hl(0, '@tag.attribute.svelte', { fg = '#B98D7B', bold = false })
    end)
  end,
}
