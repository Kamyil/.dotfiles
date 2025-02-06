return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  enabled = true,
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable('make') == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    { 'nvim-telescope/telescope-file-browser.nvim' },
    { 'nvim-telescope/telescope-media-files.nvim' },
    { 'https://codeberg.org/elfahor/telescope-just.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },

    -- Useful for getting list of installed plugins and opening them in a browser
    { 'tsakirist/telescope-lazy.nvim' },
  },
  config = function()
    -- Custom Telescope Previewer Maker to Disable Tree-sitter for Large Files
    local telescope = require('telescope')
    local actions = require('telescope.actions')

    -- Function to disable Tree-sitter and syntax highlighting for a buffer
    local function disable_syntax(bufnr)
      -- Disable Tree-sitter highlighting
      vim.cmd('TSBufDisable highlight')

      -- Optionally disable regular syntax highlighting
      vim.cmd('syntax off')

      -- Optionally set filetype to 'text'
      vim.bo[bufnr].filetype = 'text'

      -- Notify the user
      vim.notify('Syntax highlighting disabled for large file: ' .. bufnr, vim.log.levels.INFO)
    end
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup({
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      -- defaults = {
      --   mappings = {
      --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
      --   },
      -- },
      defaults = {

        -- Override the default buffer_previewer_maker, to disable Tree-sitter for big files, to not freeze Neovim
        buffer_previewer_maker = function(filepath, bufnr, opts)
          local MAX_FILESIZE = 1000000 -- 1,000,000 bytes = ~1MB, adjust as needed

          -- Attempt to get file statistics
          local ok, stats = pcall(vim.loop.fs_stat, filepath)
          if ok and stats and stats.size > MAX_FILESIZE then
            -- Disable Tree-sitter and syntax highlighting for large files
            disable_syntax(bufnr)
          end

          -- Call the default buffer_previewer_maker
          require('telescope.previewers').buffer_previewer_maker(filepath, bufnr, opts)
        end,

        mappings = {
          -- Insert mode mappings
          i = {
            ['<C-j>'] = actions.move_selection_next, -- Ctrl+j to move down
            ['<C-k>'] = actions.move_selection_previous, -- Ctrl+k to move up

            -- Optional: Cycle through history
            ['<C-n>'] = actions.cycle_history_next,
            ['<C-p>'] = actions.cycle_history_prev,

            -- Disable arrow keys if desired
            ['<Down>'] = false,
            ['<Up>'] = false,
          },
          -- Normal mode mappings
          n = {
            ['<C-j>'] = actions.move_selection_next, -- Ctrl+j to move down
            ['<C-k>'] = actions.move_selection_previous, -- Ctrl+k to move up

            -- Optional: Cycle through history
            ['<C-n>'] = actions.cycle_history_next,
            ['<C-p>'] = actions.cycle_history_prev,

            -- Disable arrow keys if desired
            ['<Down>'] = false,
            ['<Up>'] = false,
          },
        },
      },
      pickers = {
        find_files = {
          theme = 'dropdown',
        },
        buffers = {
          show_all_buffers = true,
          sort_mru = true,
          mappings = {
            n = {
              ['<c-d>'] = 'delete_buffer',
            },
            i = {
              ['<c-d>'] = 'delete_buffer',
            },
          },
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    })

    -- local colors = require('catppuccin.palettes').get_palette()
    -- local TelescopeColor = {
    --   TelescopeMatching = { fg = colors.flamingo },
    --   TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },
    --
    --   TelescopePromptPrefix = { bg = colors.surface0 },
    --   TelescopePromptNormal = { bg = colors.surface0 },
    --   TelescopeResultsNormal = { bg = colors.mantle },
    --   TelescopePreviewNormal = { bg = colors.mantle },
    --   TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
    --   TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
    --   TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
    --   TelescopePromptTitle = { bg = colors.pink, fg = colors.mantle },
    --   TelescopeResultsTitle = { fg = colors.mantle },
    --   TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },
    -- }

    -- for hl, col in pairs(TelescopeColor) do
    --   vim.api.nvim_set_hl(0, hl, col)
    -- end

    -- These are the default values
    require('file_history').setup({
      -- This is the location where it will create your file history repository
      backup_dir = '~/.file-history-git',
      -- command line to execute git
      git_cmd = 'git',
    })

    -- Enable Telescope extensions if they are installed
    -- pcall(require('telescope').load_extension, 'fzf')
    -- pcall(require('telescope').load_extension, 'ui-select')
    -- pcall(require('telescope').load_extension, 'lazy')
    -- pcall(require('telescope').load_extension, 'lazygit')
    -- pcall(require('telescope').load_extension, 'file_history')

    require('telescope').load_extension('fzf')
    require('telescope').load_extension('ui-select')
    require('telescope').load_extension('lazy')
    require('telescope').load_extension('file_history')
    require('telescope').load_extension('file_browser')

    -- Auto center on entering live_grep results
    vim.cmd([[
        augroup TelescopeAutoCenter
        autocmd!
        autocmd User TelescopePreviewerLoaded lua vim.cmd('normal! zz')
        augroup END
        ]])

    -- See `:help telescope.builtin`
  end,
}
