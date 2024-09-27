return {
  'shortcuts/no-neck-pain.nvim',
  version = '*',
  opts = {
    debug = true,
    -- The width of the focused window that will be centered. When the terminal width is less than the `width` option, the side buffers won't be created.
    --- @type integer|"textwidth"|"colorcolumn"
    width = 150,
    -- Adds autocmd (@see `:h autocmd`) which aims at automatically enabling the plugin.
    --- @type table
    autocmds = {
      -- When `true`, enables the plugin when you start Neovim.
      -- If the main window is  a side tree (e.g. NvimTree) or a dashboard, the command is delayed until it finds a valid window.
      -- The command is cleaned once it has successfuly ran once.
      --- @type boolean
      enableOnVimEnter = true,
      -- When `true`, enables the plugin when you enter a new Tab.
      -- note: it does not trigger if you come back to an existing tab, to prevent unwanted interfer with user's decisions.
      --- @type boolean
      enableOnTabEnter = true,
      -- When `true`, reloads the plugin configuration after a colorscheme change.
      --- @type boolean
      reloadOnColorSchemeChange = false,
      -- When `true`, entering one of no-neck-pain side buffer will automatically skip it and go to the next available buffer.
      --- @type boolean
      skipEnteringNoNeckPainBuffer = false,
    },
    buffers = {
      colors = {
        blend = -0.2,
      },
      scratchPad = {
        -- set to `false` to
        -- disable auto-saving
        enabled = true,
        -- set to `nil` to default
        -- to current working directory
        location = './',
      },
      bo = {
        filetype = 'md',
      },
      wo = {
        fillchars = 'eob: ',
      },
      right = {
        enabled = false,
      },
    },
    -- Supported integrations that might clash with `no-neck-pain.nvim`'s behavior.
    --- @type table
    integrations = {
      -- By default, if NeoTree is open, we will close it and reopen it when enabling the plugin,
      -- this prevents having the side buffers wrongly positioned.
      -- @link https://github.com/nvim-neo-tree/neo-tree.nvim
      NeoTree = {
        position = 'left',
        -- When `true`, if the tree was opened before enabling the plugin, we will reopen it.
        reopen = true,
      },
    },
  },
}
