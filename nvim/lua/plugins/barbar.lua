-- For having tabs
return {
  'romgrk/barbar.nvim',
  enabled = true,
  dependencies = {
    'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
    'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
  },
  init = function()
    vim.g.barbar_auto_setup = true
  end,
  opts = {
    -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
    -- animation = true,
    -- insert_at_start = true,
    -- …etc.

    icons = {
      -- Configure the base icons on the bufferline.
      -- Valid options to display the buffer index and -number are `true`, 'superscript' and 'subscript'

      buffer_index = true,
      buffer_number = false,
      button = '',
      -- Enables / disables diagnostic symbols
      diagnostics = {
        [vim.diagnostic.severity.ERROR] = { enabled = true, icon = 'ﬀ' },
        [vim.diagnostic.severity.WARN] = { enabled = false },
        [vim.diagnostic.severity.INFO] = { enabled = false },
        [vim.diagnostic.severity.HINT] = { enabled = false },
      },
      gitsigns = {
        added = { enabled = false, icon = '+' },
        changed = { enabled = false, icon = '~' },
        deleted = { enabled = false, icon = '-' },
      },
      filetype = {
        -- Sets the icon's highlight group.
        -- If false, will use nvim-web-devicons colors
        custom_colors = false,

        -- Requires `nvim-web-devicons` if `true`
        enabled = true,
      },
      separator = { left = ' ▎', right = '' },

      -- If true, add an additional separator at the end of the buffer list
      separator_at_end = true,

      -- Configure the icons on the bufferline when modified or pinned.
      -- Supports all the base icon options.
      modified = { button = '●' },
      pinned = { button = '', filename = true },

      -- Use a preconfigured buffer appearance— can be 'default', 'powerline', or 'slanted'
      preset = 'default',

      -- Configure the icons on the bufferline based on the visibility of a buffer.
      -- Supports all the base icon options, plus `modified` and `pinned`.
      alternate = { filetype = { enabled = true } },
      current = { buffer_index = true },
      inactive = { button = '×' },
      visible = { modified = { buffer_number = false } },
    },
    no_name_title = nil,
    -- Set the filetypes which barbar will offset itself for
    sidebar_filetypes = {
      -- markdown = {
      --   text = 'no-neck-pain',
      --   align = 'center', -- *optionally* specify an alignment (either 'left', 'center', or 'right')
      -- },
      ---- Use the default values: {event = 'BufWinLeave', text = '', align = 'left'}
      --NvimTree = true,
      ---- Or, specify the text used for the offset:
      undotree = {
        text = 'undotree',
        align = 'center', -- *optionally* specify an alignment (either 'left', 'center', or 'right')
      },
      ---- Or, specify the event which the sidebar executes when leaving:
      ['neo-tree'] = { event = 'BufWipeout' },
      ---- Or, specify all three
      Outline = { event = 'BufWinLeave', text = 'symbols-outline', align = 'right' },
    },
  },
  version = '^1.0.0', -- optional: only update when a new 1.x version is released
}
