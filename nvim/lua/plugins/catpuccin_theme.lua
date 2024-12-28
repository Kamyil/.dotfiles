return {
  'catppuccin/nvim',
  enabled = false,
  name = 'catppuccin',
  lazy = true,
  priority = 1000,
  init = function()
    -- Load the colorscheme here.
    -- Like many other themes, this one has different styles, and you could load
    -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
    vim.cmd.colorscheme('catppuccin-mocha')

    -- You can configure highlights by doing something like:
    vim.cmd.hi('Comment gui=none')
  end,
  setup = {
    flavour = 'mocha', -- latte, frappe, macchiato, mocha
    background = { -- :h background
      light = 'latte',
      dark = 'mocha',
    },
    transparent_background = true, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
      enabled = true, -- dims the background color of inactive window
      shade = 'dark',
      percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = true, -- Force no italic
    no_bold = true, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
      comments = { 'NONE' }, -- This removes italics from comments
      conditionals = { 'NONE' },
      loops = { 'NONE' },
      functions = { 'NONE' },
      keywords = { 'NONE' },
      strings = { 'NONE' },
      variables = { 'NONE' },
      numbers = { 'NONE' },
      booleans = { 'NONE' },
      properties = { 'NONE' },
      types = { 'NONE' },
      operators = { 'NONE' },
    },
    custom_highlights = {
      Comment = { style = 'NONE' }, -- Disable italics in comments
      Function = { style = 'NONE' }, -- Disable italics in function names
      Keyword = { style = 'NONE' }, -- Disable italics in keywords
    },
    default_integrations = false,
    integrations = {
      cmp = true,
      blink = true,
      yazi = true,
      treesitter = true,
      notify = true,
      telescope = false,
      barbar = false,
      gitsigns = true,
      neotree = true,
      which_key = true,
      harpoon = true,
      lualine = true,

      mini = {
        enabled = true,
        indentscope_color = '',
      },
      -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
  },
}
