local ts_parser_install_dir = require('config.options').ts_parser_install_dir

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- DEPENDENCIES --
  'nvim-lua/plenary.nvim', -- Dependency of most plugins below
  'rafamadriz/friendly-snippets', -- Dependency of blink.cmp
  'SmiteshP/nvim-navic', -- Dependency of barbecue plugin (breadcrumbs)

  -- LSP
  'mason-org/mason.nvim', -- LSPs & Formatters installer
  'neovim/nvim-lspconfig', -- Baked-in, ready-to-use LSP configs to not configure them manually
  'williamboman/mason-lspconfig.nvim', -- Configs
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  'folke/snacks.nvim', -- Collection of quality of life plugins that are useful for most people

  'utilyre/barbecue.nvim', -- Showing breadcrumbs at the top of the screen

  -- Misc --
  'nvim-tree/nvim-web-devicons', -- Icons
  'chentoast/marks.nvim', -- Show marks next to line number if there is one (and make them last when quitting Neovim)
  'folke/which-key.nvim', -- Shows available shortcuts when hitting <leader> or some motion
  'windwp/nvim-autopairs', -- Autopair brackets, strings etc.
  'smithbm2316/centerpad.nvim',
  'mvllow/modes.nvim',
  {
    'folke/zen-mode.nvim',
    keys = {
      { '<leader>z', '<cmd>ZenMode<cr>', desc = 'Toggle Zen Mode' },
      { '<C-.>', '<cmd>ZenMode<cr>', desc = 'Toggle Zen Mode' },
    },
    opts = {
      window = {
        backdrop = 0.95,
        width = 0.60,
        height = 1,
        options = {
          number = false,
          relativenumber = false,
          signcolumn = 'no',
          foldcolumn = '0',
          cursorline = false,
          cursorcolumn = false,
          list = false,
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = false,
          showcmd = false,
          laststatus = 0,
        },
        twilight = { enabled = false },
        gitsigns = { enabled = false },
        tmux = { enabled = false },
        todo = { enabled = false },
      },
    },
  },
  {
    'lmilojevicc/herdr-splits.nvim',
    cond = vim.env.HERDR_ENV == '1',
    event = 'VeryLazy',
    config = function()
      require('herdr-splits').setup({
        default_amount = 0.05,
        neovim_amount = 3,
        at_edge = 'wrap',
        ignore_previewwindows = true,
      })
    end,
  },
  {
    'lmilojevicc/herdr-splits.nvim',
    cond = vim.env.HERDR_ENV == '1',
    event = 'VeryLazy',
    config = function()
      require('herdr-splits').setup({
        default_amount = 0.05,
        neovim_amount = 3,
        at_edge = 'wrap',
        ignore_previewwindows = true,
      })
    end,
  },
  {
    'Saghen/blink.cmp',
    version = '1.*',
  }, -- Better Autocompletion

  -- AI

  -- Indentation / tabstop
  'lukas-reineke/indent-blankline.nvim', -- Add indentation guides even on blank lines
  'farmergreg/vim-lastplace', -- Automatically jump to the last cursor position
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- Active theme and one contrasting fallback selected by scripts/theme.
  { 'thesimonho/kanagawa-paper.nvim', lazy = false },
  -- Opt-in colorscheme experiments:
  --   NVIM_EXPERIMENTS=1 nvim                 (Luna)
  --   NVIM_EXPERIMENTS_THEME=cendre nvim      (Cendre)
  {
    'wtfox/luna.nvim',
    lazy = false,
    priority = 1000,
    cond = function()
      return vim.env.NVIM_EXPERIMENTS == '1' or vim.env.NVIM_EXPERIMENTS_THEME == 'luna'
    end,
    opts = {
      transparent = false,
      accent = 1.0,
      plugins = { all = true, auto = true },
    },
  },
  {
    'Aejkatappaja/cendre',
    lazy = false,
    priority = 1000,
    cond = function()
      return vim.env.NVIM_EXPERIMENTS_THEME == 'cendre'
    end,
    opts = {
      background = 'hard',
      italic_virtual_text = false,
      italic_comments = false,
    },
  },
  { 'sainnhe/gruvbox-material', lazy = false },

  'nvim-lualine/lualine.nvim', -- Statusline

  {
    'A7Lavinraj/fyler.nvim',
    dependencies = { 'nvim-mini/mini.icons' },
    lazy = false, -- Necessary for `default_explorer` to work properly
    opts = {
      integrations = {
        icon = 'nvim_web_devicons',
      },
      ui = {
        -- Fyler applies the dotfiles filter to the root itself. Keep a
        -- hidden working directory visible without exposing its children.
        hidden_items = {
          always_visible = { '^' .. vim.pesc(vim.fn.getcwd()) .. '$' },
        },
      },
      views = {
        finder = {
          close_on_select = false,
          columns_order = { 'git', 'link', 'diagnostic', 'size', 'permission' },
          follow_current_file = true,
          win = {
            kind = 'split_left',
          },
        },
      },
    },
  },
  'ibhagwan/fzf-lua', -- Other very fast picker for other things than files
  {
    'dmtrKovalenko/fff.nvim', -- Fast fuzzy file finder with pre-built Rust binary
    build = vim.fn.filereadable('/etc/NIXOS') == 1 and 'nix run .#release' or function()
      require('fff.download').download_or_build_binary()
    end,
    lazy = false,
  },
  'echasnovski/mini.surround', -- Allows to surround selected text with brackets, quotes, tags etc.
  'gbprod/php-enhanced-treesitter.nvim', -- Improves PHP Treesitter injections, including SQL in strings/heredocs
  {
    'nvim-treesitter/nvim-treesitter', -- Tresitter (for coloring syntax and doing AST-based operations)
    lazy = false,
    config = function()
      local languages = { 'svelte', 'typescript', 'tsx', 'javascript', 'html', 'css', 'php', 'sql', 'rust', 'markdown', 'markdown_inline' }
      vim.opt.runtimepath:prepend(ts_parser_install_dir)

      local ok_new, ts = pcall(require, 'nvim-treesitter')
      if ok_new and type(ts.setup) == 'function' then
        ts.setup({
          install_dir = ts_parser_install_dir,
        })
        ts.install(languages)
      else
        local ok_old, treesitter_configs = pcall(require, 'nvim-treesitter.configs')
        if ok_old then
          treesitter_configs.setup({
            ensure_installed = languages,
            auto_install = true,
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
          })
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('TreesitterHighlightStart', { clear = true }),
        pattern = languages,
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
  },
  {
    'rcarriga/nvim-notify',
    opts = {
      background_colour = '#000000',
    },
  },
  {
    'bojackduy/nvim-herdr-navigation',
    submodules = false,
    cond = function()
      return vim.env.HERDR_PANE_ID ~= nil
    end,
    event = 'VeryLazy',
    init = function(plugin)
      vim.opt.rtp:prepend(plugin.dir .. '/nvim-herdr-navigation')
    end,
    config = function()
      vim.schedule(function()
        require('herdr-navigation').setup({
          keybindings = {
            left = '<C-h>',
            down = '<C-j>',
            up = '<C-k>',
            right = '<C-l>',
          },
        })
      end)
    end,
  },
  'mluders/comfy-line-numbers.nvim', -- More comfortable vertical motions (without needing to reach so far away from current buttons)
  'brenoprata10/nvim-highlight-colors', -- Highlight color codes
  'folke/lazydev.nvim', -- Better neovim config editing, without any non-valid warnings
  'folke/todo-comments.nvim', -- Highlight comments like TODO, FIXME, BUG, INFO etc.

  -- Git
  { 'akinsho/git-conflict.nvim', version = '*', config = true }, -- Coloring Git Conflict inline
  'FabijanZulj/blame.nvim', -- Show git blame info in the gutter

  -- Harpoon
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2', -- For better switching between files. Add files to the jumplist and switch between them with Alt+1,2,3,4,5. Also edit jumplist like a vim buffer
  },

  -- Markdown notetaking
  'epwalsh/obsidian.nvim',
  'bullets-vim/bullets.vim',
  'MeanderingProgrammer/render-markdown.nvim',
  {
    '3rd/image.nvim',
    lazy = true,
    build = false, -- ImageMagick is provided by Nix
    ft = { 'markdown', 'quarto' },
    opts = {
      backend = 'kitty',
      processor = 'magick_cli',
      integrations = {
        markdown = {
          enabled = true,
          download_remote_images = true,
          only_render_image_at_cursor = true,
          only_render_image_at_cursor_mode = 'popup',
          filetypes = { 'markdown', 'quarto' },
        },
        obsidian = {
          enabled = true,
          download_remote_images = true,
          only_render_image_at_cursor = true,
          only_render_image_at_cursor_mode = 'popup',
          filetypes = { 'markdown', 'quarto' },
        },
      },
    },
  },
  'bngarren/checkmate.nvim',
  -- Database
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = {
      'DB',
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_winwidth = 36
      vim.g.db_ui_save_location = vim.fn.stdpath('data') .. '/db_ui'
      vim.g.db_ui_default_query = 'select * from "{table}" limit 100'
      vim.g.db_ui_env_variable_url = 'DATABASE_URL'
      vim.g.db_ui_env_variable_name = 'DATABASE_NAME'
      vim.g.db_ui_auto_execute_table_helpers = 0
    end,
  },

  { 'mbbill/undotree', cmd = 'UndotreeToggle' }, -- Undo history visualizer
}, {
  defaults = {
    lazy = true,
  },
  git = {
    -- Rust-backed plugins can take much longer than Lazy's two-minute default on a cold Nix build.
    timeout = 3600,
  },
})
