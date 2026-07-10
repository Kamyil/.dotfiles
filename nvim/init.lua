-- REQUIRES NVIM v0.10.0+ to work with lazy.nvim package manager

-- OPTIONS -- (boring but important stuff)
vim.o.number = true
vim.o.relativenumber = false
vim.o.signcolumn =
'yes'                                                  -- will use 3 columns to make line numbers have a little bit more margin
vim.o.termguicolors = true                             -- Enable nice colors
vim.o.wrap = false                                     -- Disable line wrap
vim.o.tabstop = 4                                      -- set Tabs as default (where Tab = 4 Spaces here)
vim.opt.softtabstop = 4                                -- Number of spaces that a <Tab> counts for while performing editing operations
vim.opt.shiftwidth = 4                                 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = false                              -- Use tabs instead of spaces
vim.o.swapfile = false                                 -- it's annoying when saving, and opening project back again, so turning that off
vim.o.showmode = false                                 -- Don't show mode in command line (lualine shows it)
vim.g.mapleader = ' '                                  -- Map leader to Space key
vim.g.maplocalleader = ' '                             -- Sets the local leader key to <space>
-- vim.opt.winborder set after theme loads (see below)
vim.o.clipboard = 'unnamedplus'                        -- For Windows it's gonna be different
vim.g.have_nerd_font = true                            -- Enables Nerd Font support for icons
-- vim.o.guifont = 'Berkeley Mono SemiCondensed:h12'
vim.o.encoding = 'utf-8'                               -- Sets the internal encoding
vim.o.fileencoding = 'utf-8'                           -- Sets the encoding for the current file
vim.o.fileencodings = 'utf-8'                          -- Sets the list of encodings to try when reading a file
vim.o.cursorline = false                               -- Don't highlight the line under the cursor
vim.opt.laststatus = 3                                 -- 0: Never, 1: Only if there are at least two windows, 2: Always, 3: Global statusline
vim.opt.undodir = vim.fn.stdpath('data') .. '/undodir' -- Directory to store undo history
vim.opt.undofile = true                                -- Enable persistent undo
vim.opt.updatetime = 100                               -- Time in milliseconds to wait before triggering the swap/undo file write (default 4000)
vim.opt.incsearch = true                               -- Show search matches as you type
vim.opt.mouse = 'a'                                    -- Enable mouse support in all modes
vim.opt.breakindent = true                             -- Enable break indent (preserves indentation in wrapped lines)
vim.opt.timeoutlen = 200                               -- Time in ms to wait for a mapped sequence to complete
-- Enable settings per project
vim.g.editorconfig = true                              -- Enable EditorConfig support

-- Enhanced indentation detection settings
vim.opt.autoindent = true -- Copy indent from current line when starting a new line
vim.opt.smartindent = true -- Do smart autoindenting when starting a new line
vim.opt.cindent = true -- Use C-style indenting
vim.opt.preserveindent = true -- Preserve the structure of existing lines when editing
-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 8 -- Keep 8 lines visible above/below the cursor
vim.opt.ruler = false -- Don't show the ruler (line/column info)
vim.opt.sidescrolloff = 8 -- Keep 8 columns visible to the left/right of the cursor
-- Enable icons (`nvim-tree/nvim-web-devicons` plugin in this case)
vim.g.icons_enabled = true -- Enable icons in plugins
vim.opt.listchars = {
	tab = '→ ', -- Show tabs as arrows
	trail = '·', -- Show trailing spaces
	nbsp = '␣', -- Show non-breaking spaces
	lead = '·', -- Show leading spaces (when expandtab is on)
	extends = '❯', -- Show when line continues beyond screen
	precedes = '❮', -- Show when line starts before screen
}
vim.opt.list = true -- Show whitespace characters
vim.opt.fillchars = { eob = ' ' } -- Change the character at the end of buffer (empty lines)
vim.g.loaded_netrw = 1 -- disable netrw (default file explorer)
vim.g.loaded_netrwPlugin = 1 --  disable netrw plugin
vim.opt.conceallevel = 0 -- so that `` is visible in markdown files
vim.opt.ignorecase = true -- ignore case in search patterns (again, for redundancy)
vim.opt.smartcase = true -- smart case (again, for redundancy)
vim.opt.smartindent = true -- make indenting smarter again

-- Folding (treesitter-based)
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldlevel = 99 -- Start with all folds open
vim.o.foldenable = true

-- Toggle spell check
vim.opt.spell = false                    -- Disable spell checking by default
vim.opt.spelllang = { 'en_us', 'pl_PL' } -- Set spell check languages

-- vim.opt.winborder set after theme loads (see after colorscheme)
vim.g.autoformat = false -- Disable autoformatting by default

-- Keep Tree-sitter parsers in a deterministic runtime path location.
-- This avoids parser visibility issues when plugin manager paths change.
local ts_parser_install_dir = vim.fn.stdpath('data') .. '/ts-parsers'
vim.fn.mkdir(ts_parser_install_dir .. '/parser', 'p')

-- Enable default LSP inline diagnostic
vim.diagnostic.config({
	-- virtual_text = false,                       -- Ensure virtual text is disabled since lsp_lines handles it
	-- virtual_lines = { only_current_line = false }, -- Show virtual lines for all lines
	-- underline = true,                           -- Underline diagnostics
	severity_sort = true, -- Sort diagnostics by severity
	underline = true,
	virtual_text = {
		spacing = 2,
		prefix = '●',
	},
	virtual_lines = false,
	update_in_insert = true,
	signs = {
		text = {
			-- signs via https://github.com/ricbermo/yanc/blob/main/lua/utils.lua. Thanks ricbermo!
			[vim.diagnostic.severity.ERROR] = '',
			[vim.diagnostic.severity.WARN] = '',
			[vim.diagnostic.severity.HINT] = '',
			[vim.diagnostic.severity.INFO] = '',
		},
	},
})

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
	'nvim-lua/plenary.nvim',     -- Dependency of most plugins below
	'rafamadriz/friendly-snippets', -- Dependency of blink.cmp
	'SmiteshP/nvim-navic',       -- Dependency of barbecue plugin (breadcrumbs)

	-- LSP
	'mason-org/mason.nvim',           -- LSPs & Formatters installer
	'neovim/nvim-lspconfig',          -- Baked-in, ready-to-use LSP configs to not configure them manually
	'williamboman/mason-lspconfig.nvim', -- Configs
	'WhoIsSethDaniel/mason-tool-installer.nvim',
	'folke/snacks.nvim',              -- Collection of quality of life plugins that are useful for most people

	'utilyre/barbecue.nvim',          -- Showing breadcrumbs at the top of the screen

	-- Misc --
	'nvim-tree/nvim-web-devicons',         -- Icons
	'chentoast/marks.nvim',                -- Show marks next to line number if there is one (and make them last when quitting Neovim)
	'folke/which-key.nvim',                -- Shows available shortcuts when hitting <leader> or some motion
	'windwp/nvim-autopairs',               -- Autopair brackets, strings etc.
	'smithbm2316/centerpad.nvim',
	'mvllow/modes.nvim',
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
		keys = {
			{ '<C-h>', function() require('herdr-splits').move_cursor_left() end, desc = 'Navigate left' },
			{ '<C-j>', function() require('herdr-splits').move_cursor_down() end, desc = 'Navigate down' },
			{ '<C-k>', function() require('herdr-splits').move_cursor_up() end, desc = 'Navigate up' },
			{ '<C-l>', function() require('herdr-splits').move_cursor_right() end, desc = 'Navigate right' },
			{ '<M-h>', function() require('herdr-splits').resize_left() end, desc = 'Resize left' },
			{ '<M-j>', function() require('herdr-splits').resize_down() end, desc = 'Resize down' },
			{ '<M-k>', function() require('herdr-splits').resize_up() end, desc = 'Resize up' },
			{ '<M-l>', function() require('herdr-splits').resize_right() end, desc = 'Resize right' },
		},
	},
	{
		'Saghen/blink.cmp',
		version = '1.*',
	}, -- Better Autocompletion

	-- AI

	-- Indentation / tabstop
	'lukas-reineke/indent-blankline.nvim', -- Add indentation guides even on blank lines
	'farmergreg/vim-lastplace',         -- Automatically jump to the last cursor position
	'tpope/vim-sleuth',                 -- Detect tabstop and shiftwidth automatically

	-- Themes / Colorschemes
	{ 'sho-87/kanagawa-paper.nvim',       lazy = false }, -- Colorscheme / theme
	{ 'thesimonho/kanagawa-paper.nvim',   lazy = false }, -- Colorscheme / theme
	{ 'catppuccin/nvim',                  lazy = false }, -- Alternative colorscheme
	{ 'vague-theme/vague.nvim',           lazy = false }, -- Alternative colorscheme
	{ 'ramojus/mellifluous.nvim',         lazy = false }, -- Alternative colorscheme
	{ 'xero/miasma.nvim',                 lazy = false }, -- Alternative colorscheme
	{ 'RRethy/base16-nvim',               lazy = false }, -- Alternative colorscheme
	{ 'rose-pine/neovim',                 lazy = false }, -- Alternative colorscheme
	{ 'sainnhe/gruvbox-material',         lazy = false }, -- Alternative colorscheme
	{ 'folke/tokyonight.nvim',            lazy = false }, -- Alternative colorscheme
	{ 'datsfilipe/vesper.nvim',           lazy = false }, -- Alternative colorscheme
	{ 'scottmckendry/cyberdream.nvim',    lazy = false }, -- Alternative colorscheme
	{ 'ember-theme/nvim',                 lazy = false }, -- Alternative colorscheme
	{ 'aktersnurra/no-clown-fiesta.nvim', lazy = false }, -- Alternative colorscheme
	{ 'marko-cerovac/material.nvim',      lazy = false }, -- Alternative colorscheme
	{ 'Mofiqul/vscode.nvim',              lazy = false }, -- Alternative colorscheme
	{ 'AlexvZyl/nordic.nvim',             lazy = false }, -- Alternative colorscheme
	{ 'FrenzyExists/aquarium-vim',        lazy = false }, -- Alternative colorscheme
	{ 'smit4k/shale.nvim',                lazy = false }, -- Alternative colorscheme


	{
		'everviolet/nvim',
		name = 'evergarden',
		priority = 1000, -- Colorscheme plugin is loaded first before any other plugins
		opts = {
			theme = {
				variant = 'winter', -- 'winter'|'fall'|'spring'|'summer'
				accent = 'green',
			},
			editor = {
				transparent_background = true,
				sign = { color = 'none' },
				float = {
					color = 'mantle',
					solid_border = false,
				},
				completion = {
					color = 'surface0',
				},
			},
		},
	},

	'nvim-lualine/lualine.nvim', -- Statusline

	{
		'A7Lavinraj/fyler.nvim',
		dependencies = { 'nvim-mini/mini.icons' },
		lazy = false, -- Necessary for `default_explorer` to work properly
		opts = {
			integrations = {
				icon = 'nvim_web_devicons',
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
	'ibhagwan/fzf-lua',     -- Other very fast picker for other things than files
	{
		'dmtrKovalenko/fff.nvim', -- Fast fuzzy file finder with pre-built Rust binary
		build = function()
			require('fff.download').download_or_build_binary()
		end,
		lazy = false,
	},
	'echasnovski/mini.surround',        -- Allows to surround selected text with brackets, quotes, tags etc.
	'gbprod/php-enhanced-treesitter.nvim', -- Improves PHP Treesitter injections, including SQL in strings/heredocs
	{
		'nvim-treesitter/nvim-treesitter', -- Tresitter (for coloring syntax and doing AST-based operations)
		lazy = false,
		config = function()
			local languages = { 'svelte', 'typescript', 'tsx', 'javascript', 'html', 'css', 'php', 'sql', 'rust' }
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

		'mrjones2014/smart-splits.nvim', -- Better navigation between Neovim and Kitty splits
		build = './kitty/install-kittens.bash',
	},
	'folke/lazydev.nvim',              -- Better neovim config editing, without any non-valid warnings
	'folke/todo-comments.nvim',        -- Highlight comments like TODO, FIXME, BUG, INFO etc.
	'mluders/comfy-line-numbers.nvim', -- More comfortable vertical motions (without needing to reach so far away from current buttons)
	'brenoprata10/nvim-highlight-colors', -- Highlight color codes

	-- Git
	{ 'akinsho/git-conflict.nvim', version = '*',         config = true }, -- Coloring Git Conflict inline
	'FabijanZulj/blame.nvim',                                           -- Show git blame info in the gutter

	-- Harpoon
	{
		'ThePrimeagen/harpoon',
		branch = 'harpoon2', -- For better switching between files. Add files to the jumplist and switch between them with Alt+1,2,3,4,5. Also edit jumplist like a vim buffer
	},

	-- Markdown notetaking
	'epwalsh/obsidian.nvim',
	'bullets-vim/bullets.vim',
	'MeanderingProgrammer/render-markdown.nvim',
	'bngarren/checkmate.nvim',
	-- {
	--   'Kamyil/markdown-agenda.nvim',
	--   lazy = false,
	--   opts = {
	--     directory = '~/second-brain',
	--     keymaps = {
	--       open = false,
	--     },
	--   },
	-- },
	{
		dir = '/Users/kamil/Personal/Projects/markdown-agenda.nvim',
		name = 'markdown-agenda.nvim',
		cmd = 'MarkdownAgenda',
		opts = {
			directory = '/Users/kamil/Personal/Projects/markdown-agenda.nvim',
			recursive = false,
			date_format = '%Y-%m-%d',
			help = false,
			calendar = {
				enabled = true,
				position = 'right',
				months_to_show = 4,
				grid_columns = 2,
				week_start = 'monday', -- or "sunday"
			},
			keymaps = {
				open = '<leader>na',
			},
		},
	},
	{
		dir = '/Users/kamil/Personal/Projects/deebee.nvim',
		name = 'deebee.nvim',
		cmd = {
			'DeebeeOpen',
			'DeebeeConnect',
			'DeebeeDisconnect',
			'DeebeeRun',
			'DeebeeNextPage',
			'DeebeePrevPage',
			'DeebeeRefreshExplorer',
			'DeebeeInstall',
			'DeebeeUpdateWorker',
			'DeebeeWorkerInfo',
		},
		init = function()
			vim.g.deebee_worker_path = '/Users/kamil/Personal/Projects/deebee.nvim/target/debug/deebee-worker'
		end,
		opts = {
			default_connection = 'deebee-local',
			query_page_size = 100,
			connections = {
				{
					id = 'deebee-local',
					name = 'Deebee Local Postgres',
					adapter = 'postgres',
					dsn = 'postgres://deebee:deebee@localhost:55432/deebee',
				},
			},
		},
	},

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

	{ 'mbbill/undotree',           cmd = 'UndotreeToggle' }, -- Undo history visualizer
}, {
	defaults = {
		lazy = true,
	},
})

-- # KEYMAPS #
-- Helper function for defining key mappings / key shortcuts
-- @field mode - 'n' for normal, 'v' for visual, 'i' for insert, 'x' for all
-- @field keys - keys themselves where "C-" means Ctrl+, "A-" means "Alt+", "<leader>+" means Space+
-- @field callback - command or function to execute
-- @field options - some extra options as Lua table
-- @field options.desc - Description of a keymap, that will be displayed in which-key
local keymap = vim.keymap.set

local function run_current_sql_block()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local last_line = vim.api.nvim_buf_line_count(0)

	local function is_blank(line_nr)
		return vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]:match('^%s*$') ~= nil
	end

	if is_blank(cursor_line) then
		vim.notify('No SQL block under cursor', vim.log.levels.INFO)
		return
	end

	local start_line = cursor_line
	while start_line > 1 and not is_blank(start_line - 1) do
		start_line = start_line - 1
	end

	local end_line = cursor_line
	while end_line < last_line and not is_blank(end_line + 1) do
		end_line = end_line + 1
	end

	vim.cmd(('%d,%dDB'):format(start_line, end_line))
end


require('fzf-lua').setup({
	-- Load the 'ivy' profile first
	'telescope',
	winopts = {
		-- border = borders,
	},
	oldfiles = {
		-- In Telescope, when I used <leader>fr, it would load old buffers.
		-- fzf lua does the same, but by default buffers visited in the current
		-- session are not included. I use <leader>fr all the time to switch
		-- back to buffers I was just in. If you missed this from Telescope,
		-- give it a try.
		include_current_session = true,
	},
	previewers = {
		builtin = {
			-- fzf-lua is very fast, but it really struggled to preview a couple files
			-- in a repo. Those files were very big JavaScript files (1MB, minified, all on a single line).
			-- It turns out it was Treesitter having trouble parsing the files.
			-- With this change, the previewer will not add syntax highlighting to files larger than 100KB
			-- (Yes, I know you shouldn't have 100KB minified files in source control.)
			syntax_limit_b = 1024 * 100, -- 100KB
		},
	},
	-- Provide a table of your overrides
	-- {
	-- 	keymap = {
	-- 		fzf = {
	-- 			["alt-q"] = "smart_send_to_qf",
	-- 		},
	-- 	},
	-- 	oldfiles = {
	-- 		include_current_session = true,
	-- 	},
	-- },
})

local fzf_lua = require('fzf-lua')

local function dupa() end

local function run_from_edit_window(fn)
	local current_win = vim.api.nvim_get_current_win()
	local current_buf = vim.api.nvim_win_get_buf(current_win)

	if vim.bo[current_buf].filetype == 'fyler' then
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			if win ~= current_win then
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].buftype == '' and vim.bo[buf].filetype ~= 'fyler' then
					vim.api.nvim_set_current_win(win)
					break
				end
			end
		end
	end

	fn()
end

local function toggle_fyler()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == 'fyler' then
			vim.api.nvim_win_close(win, true)
			return
		end
	end

	require('fyler').open()
end

keymap('n', '<leader>e', function()
	toggle_fyler()
end, { desc = 'File Explorer' })
keymap('x', '<C-a>', 'ggVg')
keymap('n', '<leader>ff', function()
	run_from_edit_window(function()
		require('fff').find_files()
	end)
end, { desc = '[F]ind [F]iles' })
-- keymap('n', '<leader>fF', fff.find_files, { desc = '[F]ind (ALL) [F]iles' })
keymap('n', '<leader>fw', function()
	run_from_edit_window(function()
		require('fff').live_grep()
	end)
end, { desc = '[F]ind [W]ords' })
keymap('n', '<leader>fk', fzf_lua.keymaps, { desc = '[F]ind [K]eymaps' })
-- keymap('n', '<leader>fh', ':Pick help<CR>')

keymap('n', '<F13>', function()
	toggle_fyler()
end, { desc = 'File Explorer' })
-- LSP
keymap('n', '<leader>la', vim.lsp.buf.code_action, { desc = '' })
keymap('n', '<leader>lf', vim.lsp.buf.format)
keymap('n', '<leader>lr', vim.lsp.buf.rename, { desc = '[L]SP [R]ename' })
keymap('n', 'K', vim.lsp.buf.hover)
-- Diagnostics hover is now on <leader>D instead of 'D' to preserve the default 'D' keymap
keymap('n', '<leader>D', function()
	local cur = vim.api.nvim_win_get_cursor(0)
	local line = cur[1] - 1
	local col = cur[2]
	local has_at_cursor = false
	for _, d in ipairs(vim.diagnostic.get(0, { lnum = line })) do
		if d.col and d.end_col and d.col <= col and col <= d.end_col then
			has_at_cursor = true
			break
		end
	end
	vim.diagnostic.open_float(nil, {
		scope = has_at_cursor and 'cursor' or 'line',
		focusable = false,
		-- border = borders,
		source = 'if_many',
		close_events = { 'CursorMoved', 'InsertEnter', 'BufLeave', 'WinScrolled' },
	})
end, { desc = 'Diagnostics: hover (cursor/line)' })
-- keymap('n', 'gi', vim.lsp.buf.implementation)
keymap('n', 'gd', fzf_lua.lsp_definitions, { desc = 'Go to [D]efinition' })
keymap('n', 'grr', function()
	require('snacks').picker.lsp_references()
end, { desc = '[G]o to [R]eferences' })
keymap('n', '<leader>ld', function()
	require('snacks').picker.lsp_definitions()
end, { desc = '[L]SP [D]efinitions' })
keymap('n', '<leader>lD', function()
	require('snacks').picker.lsp_references()
end, { desc = '[L]SP References' })

keymap('n', '<leader>gg', function()
	require('snacks').lazygit()
end, { desc = '[G]it [G]it (run lazygit client)' })

keymap('n', '<leader>gd', function()
	require('snacks').terminal.toggle('hunk diff', {
		cwd = vim.fn.getcwd(),
	})
end, { desc = '[G]it [D]iff (run hunk diff in floating terminal)' })

keymap('n', '<leader>db', '<cmd>DBUIToggle<CR>', { desc = '[D]atabase [B]rowser toggle' })
keymap('n', '<leader>dB', '<cmd>DBUI<CR>', { desc = '[D]atabase [B]rowser open' })
keymap('n', '<leader>da', '<cmd>DBUIAddConnection<CR>', { desc = '[D]atabase [A]dd connection' })
keymap('n', '<leader>df', '<cmd>DBUIFindBuffer<CR>', { desc = '[D]atabase [F]ind query buffer' })
keymap('n', '<leader>dr', '<cmd>%DB<CR>', { desc = '[D]atabase [R]un buffer' })
keymap('x', '<leader>dr', ':DB<CR>', { desc = '[D]atabase [R]un selection' })

vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup('dadbod-sql-keymaps', { clear = true }),
	pattern = { 'sql', 'mysql', 'plsql' },
	callback = function(args)
		vim.keymap.set({ 'n', 'i' }, '<C-CR>', function()
			if vim.fn.mode() == 'i' then
				vim.cmd('stopinsert')
			end
			run_current_sql_block()
		end, { buffer = args.buf, desc = '[D]atabase [R]un SQL block under cursor' })
	end,
})

-- Setup snacks.picker for LSP functionality
require('snacks').setup({
	picker = {
		enabled = true,
		-- Configure picker layout and appearance
		layout = {
			preset = 'telescope', -- Use telescope-like layout
			backdrop = { transparent = false },
		},
		win = {
			-- input = { border = borders },
			-- list = { border = borders },
			-- preview = { border = borders },
		},
		-- Configure sources
		sources = {
			lsp_definitions = {
				title = 'LSP Definitions',
				format = 'file',
			},
			lsp_references = {
				title = 'LSP References',
				format = 'file',
			},
		},
	},
})
require('git-conflict')
keymap('n', '<leader>gb', '<cmd>BlameToggle window<CR>', { desc = '[G]it [B]lame' })
keymap('n', '<leader>gcc', '<cmd>GitConflictChooseOurs<CR>', { desc = '[G]it [C]onflict Choose [C]urrent' })
keymap('n', '<leader>gci', '<cmd>GitConflictChooseTheirs<CR>', { desc = '[G]it [C]onflict Choose [I]ncoming' })
keymap('n', '<leader>gcb', '<cmd>GitConflictChooseBoth<CR>', { desc = '[G]it [Conflict] Choose [B]oth' })
keymap('n', '<leader>gcn', '<cmd>GitConflictChooseNone<CR>', { desc = '[G]it [Conflict] Choose [N]one' })
keymap('n', '<leader>gc[', '<cmd>GitConflictPrevConflict<CR>', { desc = '[G]it [Conflict] Previous' })
keymap('n', '<leader>gc]', '<cmd>GitConflictNextConflict<CR>', { desc = '[G]it [Conflict] Next' })

local function ensure_kitty_on_path()
	if vim.env.KITTY_LISTEN_ON == nil or vim.fn.executable('kitty') == 1 then
		return
	end

	local kitty_bin_dirs = {
		'/Applications/kitty.app/Contents/MacOS',
		vim.fn.expand('~/Applications/kitty.app/Contents/MacOS'),
		'/opt/homebrew/bin',
		'/usr/local/bin',
	}

	for _, dir in ipairs(kitty_bin_dirs) do
		if vim.fn.executable(dir .. '/kitty') == 1 then
			vim.env.PATH = dir .. ':' .. vim.env.PATH
			return
		end
	end
end

ensure_kitty_on_path()

local smart_splits = require('smart-splits')
smart_splits.setup({
	at_edge = 'stop',
	multiplexer_integration = 'kitty',
	disable_multiplexer_nav_when_zoomed = true,
})

keymap('n', '<C-h>', smart_splits.move_cursor_left, { desc = 'Move to left split' })
keymap('n', '<C-j>', smart_splits.move_cursor_down, { desc = 'Move to lower split' })
keymap('n', '<C-k>', smart_splits.move_cursor_up, { desc = 'Move to upper split' })
keymap('n', '<C-l>', smart_splits.move_cursor_right, { desc = 'Move to right split' })
keymap('n', '<C-\\>', smart_splits.move_cursor_previous, { desc = 'Move to previous split' })

vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup('fyler-smart-splits', { clear = true }),
	pattern = 'fyler',
	callback = function(args)
		vim.keymap.set('n', '<C-h>', smart_splits.move_cursor_left, { buffer = args.buf, desc = 'Move to left split' })
		vim.keymap.set('n', '<C-j>', smart_splits.move_cursor_down, { buffer = args.buf, desc = 'Move to lower split' })
		vim.keymap.set('n', '<C-k>', smart_splits.move_cursor_up, { buffer = args.buf, desc = 'Move to upper split' })
		vim.keymap.set('n', '<C-l>', smart_splits.move_cursor_right, { buffer = args.buf, desc = 'Move to right split' })
	end,
})

-- keymap('n', '<leader>o', ':update<CR> :source<CR>') -- source file inline (most useful for editing neovim config file
keymap('n', '<leader>w', ':write<CR>')
keymap('n', '<leader>u', '<cmd>UndotreeToggle<CR>', { desc = 'Toggle [U]ndotree' })
keymap('n', '<leader>q', ':qa<CR>', { desc = 'Quit Neovim completely' })

-- Note-taking keymaps (second-brain weekly notes)
local second_brain = vim.fn.expand('~/second-brain')
local weekly_dir = second_brain .. '/weekly'

local function get_iso_week_file()
	local year = vim.fn.system('date +%G'):gsub('%s+', '')
	local week = vim.fn.system('date +%V'):gsub('%s+', '')
	return weekly_dir .. '/' .. year .. '-W' .. week .. '.md'
end

keymap('n', '<leader>ni', function()
	vim.cmd('edit ' .. get_iso_week_file())
	vim.cmd('normal! G')
end, { desc = '[N]ote [I]nbox (current week)' })

keymap('n', '<leader>nw', function()
	require('fzf-lua').files({
		cwd = weekly_dir,
		prompt = 'Weekly Notes> ',
	})
end, { desc = '[N]ote [W]eekly browse' })

keymap('n', '<leader>np', function()
	local prev_week = vim.fn.system('date -v-7d +%G-W%V'):gsub('%s+', '')
	vim.cmd('edit ' .. weekly_dir .. '/' .. prev_week .. '.md')
end, { desc = '[N]ote [P]revious week' })

keymap('n', '<leader>nf', function()
	require('fzf-lua').files({
		cwd = second_brain,
		prompt = 'Find Notes> ',
	})
end, { desc = '[N]ote [F]ind by filename' })

keymap('n', '<leader>ns', function()
	require('fff').live_grep({
		cwd = second_brain,
		title = 'Search Notes',
		prompt = 'Search Notes> ',
	})
end, { desc = '[N]ote [S]earch contents' })

keymap('n', '<leader>ntt', function()
	local line = vim.api.nvim_get_current_line()
	if line:match('^%s*$') then
		vim.api.nvim_set_current_line('- [ ] ')
		vim.cmd('startinsert!')
	else
		local row = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_buf_set_lines(0, row, row, false, { '- [ ] ' })
		vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
		vim.cmd('startinsert!')
	end
end, { desc = '[N]ote [T]odo create' })

keymap('n', '<leader>ntx', function()
	local line = vim.api.nvim_get_current_line()
	if line:match('%- %[ %]') then
		vim.api.nvim_set_current_line((line:gsub('%- %[ %]', '- [x]')))
	elseif line:match('%- %[x%]') then
		vim.api.nvim_set_current_line((line:gsub('%- %[x%]', '- [ ]')))
	elseif line:match('%- %[%-%]') then
		vim.api.nvim_set_current_line((line:gsub('%- %[%-%]', '- [x]')))
	end
end, { desc = '[N]ote [T]odo toggle complete' })

keymap('n', '<leader>ntp', function()
	local line = vim.api.nvim_get_current_line()
	if line:match('%- %[ %]') then
		vim.api.nvim_set_current_line((line:gsub('%- %[ %]', '- [-]')))
	elseif line:match('%- %[%-%]') then
		vim.api.nvim_set_current_line((line:gsub('%- %[%-%]', '- [ ]')))
	elseif line:match('%- %[x%]') then
		vim.api.nvim_set_current_line((line:gsub('%- %[x%]', '- [-]')))
	end
end, { desc = '[N]ote [T]odo in progress' })

keymap('x', '<leader>nl', function()
	vim.cmd('normal! "zy')
	local text = vim.fn.getreg('z')

	vim.ui.input({ prompt = 'Link URL: ' }, function(url)
		if url and url ~= '' then
			vim.cmd('normal! gv"_c[' .. text .. '](' .. url .. ')')
		end
	end)
end, { desc = '[N]ote [L]ink from selection' })

-- local capture = require('custom.capture')
-- local timetracking = require('custom.timetracking')
-- require('custom.run-cursor-cmd')

-- keymap('n', '<leader>nc', capture.capture, { desc = '[N]ote [C]apture to weekly' })
-- keymap('n', '<leader>na', '<cmd>MarkdownAgenda<cr>', { desc = '[N]ote [A]genda view' })
--
-- keymap('n', '<leader>nts', timetracking.start, { desc = '[N]ote [T]ime [S]tart' })
-- keymap('n', '<leader>nte', timetracking.stop, { desc = '[N]ote [T]ime [E]nd' })

-- Harpoon setup (quick file switching between files that I currently work on)
local harpoon = require('harpoon')
-- local harpoon_mark = require('harpoon.mark');

harpoon:setup()

keymap('n', 'ga', function()
	harpoon:list():add()
end) -- add file to harpoon jumplist
keymap('n', 'ge', function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end) -- open jumplist with currently added items

for i = 1, 9 do
	keymap('n', '<A-' .. i .. '>', function()
		harpoon:list():select(i)
	end, { desc = 'Harpoon to file ' .. i })
end
--
-- better indenting with selected text
keymap('v', '<', '<gv')
keymap('v', '>', '>gv')

-- Paste by Replacing contents with clipboard content (without replacing what's already in register, so 'paste and keep it still')
keymap('v', '<leader>p', [["_dP]])

-- Move to prev/next item inside quickfix list, without needing to focus the list itself
keymap('n', ']q', '<cmd>cnext<CR>zz')
keymap('n', '[q', '<cmd>cprev<CR>zz')

-- Splits
keymap('n', '<leader>/', '<cmd>vsplit<CR>', { desc = 'Split vertically' })
keymap('n', '<leader>-', '<cmd>split<CR>', { desc = 'Split horizontally' })

keymap('n', '<Tab>', 'za', { desc = 'Toggle fold' })

-- Best remap ever - move selected lines up and down without leaving the selection, a.k.a move code around
keymap('v', 'J', ":m '>+1<CR>gv=gv")
keymap('v', 'K', ":m '<-2<CR>gv=gv")

-- Move lines up and down in normal modellll

-- 🇵🇱 Polish character mappings for Insert Mode
-- replace it with your own language
keymap('i', '<M-a>', 'ą')
keymap('i', '<M-c>', 'ć')
keymap('i', '<M-e>', 'ę')
keymap('i', '<M-l>', 'ł')
keymap('i', '<M-n>', 'ń')
keymap('i', '<M-o>', 'ó')
keymap('i', '<M-s>', 'ś')
keymap('i', '<M-x>', 'ź')
keymap('i', '<M-z>', 'ż')
keymap('i', '<M-A>', 'Ą') -- Uppercase versions
keymap('i', '<M-C>', 'Ć')
keymap('i', '<M-E>', 'Ę')
keymap('i', '<M-L>', 'Ł')
keymap('i', '<M-N>', 'Ń')
keymap('i', '<M-O>', 'Ó')
keymap('i', '<M-S>', 'Ś')
keymap('i', '<M-X>', 'Ź')
keymap('i', '<M-Z>', 'Ż')

-- Select all with Ctrl+A
keymap('n', '<C-a>', 'ggVG')

require('rose-pine').setup({
	styles = {
		bold = true,
		italic = false,
		transparency = true,
	},
})

require('vague').setup({
	-- Don't set background
	transparent = false,
	-- Disable bold/italic globally
	bold = true,
	italic = false,
})


-- Setup plugins, add some config to them
require('kanagawa-paper').setup({
	-- enable undercurls for underlined text
	undercurl = true,
	italic = false,
	-- transparent background
	transparent = true,
	-- highlight background for the left gutter
	gutter = false,
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

	-- adjust overall color balance for each theme [-1, 1]
	color_offset = {
		ink = { brightness = -2, saturation = -2 },
		canvas = { brightness = -0.5, saturation = -0.5 }, -- if you use light mode sometimes
	},

	auto_plugins = true,
})
-- FIXME: Kanagawa theme override: Override Svelte tag colors, to make them distinct
vim.schedule(function()
	vim.api.nvim_set_hl(0, '@tag.svelte', { fg = '#8EA4A2', bold = false })
	vim.api.nvim_set_hl(0, '@tag.attribute.svelte', { fg = '#B98D7B', bold = false })
end)

-- require('mini.pick').setup()
--
require('mini.surround').setup()
require('marks').setup()
require('nvim-autopairs').setup()

require('blink.cmp').setup({
	keymap = { preset = 'enter' },
	fuzzy = {
		implementation = 'prefer_rust_with_warning',
	},
	completion = {
		menu = {
			-- border = borders,
			draw = {
				components = {
					-- customize the drawing of kind icons
					kind_icon = {
						text = function(ctx)
							-- default kind icon
							local icon = ctx.kind_icon
							-- if LSP source, check for color derived from documentation
							if ctx.item.source_name == 'LSP' then
								local color_item = require('nvim-highlight-colors').format(ctx.item.documentation,
									{ kind = ctx.kind })
								if color_item and color_item.abbr ~= '' then
									icon = color_item.abbr
								end
							end
							return icon .. ctx.icon_gap
						end,
						highlight = function(ctx)
							-- default highlight group
							local highlight = 'BlinkCmpKind' .. ctx.kind
							-- if LSP source, check for color derived from documentation
							if ctx.item.source_name == 'LSP' then
								local color_item = require('nvim-highlight-colors').format(ctx.item.documentation,
									{ kind = ctx.kind })
								if color_item and color_item.abbr_hl_group then
									highlight = color_item.abbr_hl_group
								end
							end
							return highlight
						end,
					},
				},
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 250,
			treesitter_highlighting = true,
			window = {
				-- border = borders,
			},
		},
		list = {
			selection = { preselect = false, auto_insert = false },
		},
	},
	signature = {
		enabled = true,
		window = {
			-- border = borders,
		},
	},
	sources = {
		default = { 'lsp', 'path', 'snippets', 'buffer' },
		per_filetype = {
			codecompanion = { 'codecompanion' },
			sql = { 'dadbod', 'lsp', 'path', 'snippets', 'buffer' },
			mysql = { 'dadbod', 'lsp', 'path', 'snippets', 'buffer' },
			plsql = { 'dadbod', 'lsp', 'path', 'snippets', 'buffer' },
		},
		providers = {
			dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
		},
	},
})

require('modes').setup()

local function set_hl_link(group, target)
	vim.api.nvim_set_hl(0, group, { link = target })
end

local function apply_terminal_theme_highlights()
	set_hl_link('NormalFloat', 'Normal')
	set_hl_link('FloatBorder', 'Comment')

	set_hl_link('BlinkCmpMenu', 'Pmenu')
	set_hl_link('BlinkCmpMenuBorder', 'FloatBorder')
	set_hl_link('BlinkCmpMenuSelection', 'PmenuSel')
	set_hl_link('BlinkCmpDoc', 'NormalFloat')
	set_hl_link('BlinkCmpDocBorder', 'FloatBorder')
	set_hl_link('BlinkCmpSignatureHelp', 'NormalFloat')
	set_hl_link('BlinkCmpSignatureHelpBorder', 'FloatBorder')

	set_hl_link('FylerNormal', 'Normal')
	set_hl_link('FylerNormalNC', 'NormalNC')
	set_hl_link('FylerFloat', 'NormalFloat')
	set_hl_link('FylerFloatBorder', 'FloatBorder')
	set_hl_link('FylerFloatTitle', 'Title')
	set_hl_link('FylerBlue', 'DiagnosticInfo')
	set_hl_link('FylerGreen', 'DiagnosticOk')
	set_hl_link('FylerGrey', 'Comment')
	set_hl_link('FylerRed', 'DiagnosticError')
	set_hl_link('FylerYellow', 'DiagnosticWarn')
	set_hl_link('FylerDirectoryIcon', 'Directory')
	set_hl_link('FylerDirectoryName', 'Directory')
	set_hl_link('FylerFSDirectoryIcon', 'Directory')
	set_hl_link('FylerFSDirectoryName', 'Directory')
	set_hl_link('FylerFSFile', 'Normal')
	set_hl_link('FylerFSLink', 'Underlined')
	set_hl_link('FylerGitAdded', 'DiffAdd')
	set_hl_link('FylerGitConflict', 'DiagnosticError')
	set_hl_link('FylerGitDeleted', 'DiffDelete')
	set_hl_link('FylerGitIgnored', 'Comment')
	set_hl_link('FylerGitModified', 'DiffChange')
	set_hl_link('FylerGitRenamed', 'DiagnosticHint')
	set_hl_link('FylerGitStaged', 'DiffAdd')
	set_hl_link('FylerGitUnstaged', 'DiffChange')
	set_hl_link('FylerGitUntracked', 'Directory')
	set_hl_link('FylerGitCopied', 'DiagnosticInfo')
	set_hl_link('FylerIndentGuide', 'NonText')
	set_hl_link('FylerIndentMarker', 'NonText')
	set_hl_link('FylerWinpickMarker', 'IncSearch')
	set_hl_link('FylerWinPick', 'IncSearch')
end

apply_terminal_theme_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
	group = vim.api.nvim_create_augroup('terminal-theme-highlights', { clear = true }),
	callback = apply_terminal_theme_highlights,
})

-- Set global window border (after colorscheme loads)
vim.opt.winborder = 'rounded'

-- Autocommands
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
--
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
	desc = 'Jump to last cursor position when opening a file',
	group = vim.api.nvim_create_augroup('last-cursor-position', { clear = true }),
	callback = function()
		if vim.fn.line('\'"') > 0 then
			vim.cmd('normal! g`"')
		end
	end,
})

vim.api.nvim_create_autocmd('VimEnter', {
	desc = 'Open Fyler on startup when no file is provided',
	group = vim.api.nvim_create_augroup('fyler-startup', { clear = true }),
	callback = function()
		if #vim.api.nvim_list_uis() == 0 then
			return
		end

		local argc = vim.fn.argc()
		if argc > 1 then
			return
		end

		if argc == 1 then
			local arg0 = vim.fn.argv(0)
			if vim.fn.isdirectory(arg0) == 0 then
				return
			end
		end

		vim.schedule(function()
			if argc == 1 then
				require('fyler').open({ dir = vim.fn.argv(0) })
			else
				require('fyler').open()
			end
		end)
	end,
})

-- Set the commentstring for Smarty templates
local smarty_augroup = vim.api.nvim_create_augroup('SmartyComment', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
	desc = 'Set commentstring for Smarty templates',
	group = smarty_augroup,
	pattern = 'smarty',
	callback = function()
		vim.bo.commentstring = '{* %s *}'
	end,
})

-- Enhanced indentation detection
local indent_augroup = vim.api.nvim_create_augroup('IndentDetection', { clear = true })
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
	desc = 'Detect and apply indentation settings',
	group = indent_augroup,
	pattern = '*',
	callback = function()
		-- Let vim-sleuth handle detection first
		vim.schedule(function()
			-- Force refresh indentation display
			if vim.bo.expandtab then
				-- Using spaces
				vim.opt_local.listchars:append({ tab = '→ ', lead = '·', trail = '·' })
			else
				-- Using tabs
				vim.opt_local.listchars:append({ tab = '→ ', trail = '·' })
			end

			-- Ensure proper tab display
			vim.opt_local.tabstop = vim.bo.tabstop
			vim.opt_local.shiftwidth = vim.bo.shiftwidth
			vim.opt_local.softtabstop = vim.bo.softtabstop
		end)
	end,
})

require('comfy-line-numbers').setup({
	down_key = 'j',
	up_key = 'k',

	-- Line numbers will be completely hidden for the following file/buffer types
	hidden_file_types = { 'help', 'TelescopePrompt', 'undotree' },
	hidden_buffer_types = { 'terminal', 'blink', 'cmp' },
})
require('todo-comments').setup()
require('nvim-highlight-colors').setup({})
local wk = require('which-key')
wk.setup({
	preset = 'helix',
	win = {
		-- border = borders,
	},
})
wk.add({
	{ '<leader>a', group = 'AI', icon = '󰧑' },
	{ '<leader>aa', icon = '󰭻' },
	{ '<leader>as', icon = '󰒅' },
	{ '<leader>a+', icon = '󰐕' },
	{ '<leader>at', icon = '󰔡' },
	{ '<leader>ac', icon = '󰘳' },
	{ '<leader>an', icon = '󰎔' },
	{ '<leader>ai', icon = '󰜺' },
	{ '<leader>aA', icon = '󰑐' },

	{ '<leader>d', group = 'Database', icon = '' },
	{ '<leader>db', icon = '' },
	{ '<leader>dB', icon = '' },
	{ '<leader>da', icon = '' },
	{ '<leader>df', icon = '󰈞' },
	{ '<leader>dr', icon = '󰑐' },

	{ '<leader>f', group = 'Find', icon = '󰍉' },
	{ '<leader>ff', icon = '󰈞' },
	{ '<leader>fw', icon = '󰈬' },
	{ '<leader>fk', icon = '󰌌' },

	{ '<leader>g', group = 'Git', icon = '󰊢' },
	{ '<leader>gg', icon = '󰊢' },
	{ '<leader>gd', icon = '󰊢' },
	{ '<leader>gb', icon = '󰜘' },
	{ '<leader>gc', group = 'Conflict', icon = '󰞇' },
	{ '<leader>gcc', icon = '󰄬' },
	{ '<leader>gci', icon = '󰏫' },
	{ '<leader>gcb', icon = '󰐙' },
	{ '<leader>gcn', icon = '󰜺' },
	{ '<leader>gc[', icon = '󰒮' },
	{ '<leader>gc]', icon = '󰒭' },

	{ '<leader>l', group = 'LSP', icon = '󰒋' },
	{ '<leader>la', icon = '󰌵' },
	{ '<leader>lf', icon = '󰉢' },
	{ '<leader>lr', icon = '󰑕' },
	{ '<leader>ld', icon = '󰈮' },
	{ '<leader>lD', icon = '󰈇' },

	{ '<leader>n', group = 'Notes', icon = '󰠮' },
	{ '<leader>ni', icon = '󰻃' },
	{ '<leader>nw', icon = '󰨲' },
	{ '<leader>np', icon = '󰒮' },
	{ '<leader>nf', icon = '󰈞' },
	{ '<leader>ns', icon = '󰍉' },
	{ '<leader>nc', icon = '󰄀' },
	{ '<leader>na', icon = '󰃭' },
	{ '<leader>nt', group = 'Todo/Time', icon = '󰄲' },
	{ '<leader>ntt', icon = '󰐕' },
	{ '<leader>ntx', icon = '󰄬' },
	{ '<leader>ntp', icon = '󰦖' },
	{ '<leader>nts', icon = '󱎫' },
	{ '<leader>nte', icon = '󱎬' },

	{ '<leader>r', group = 'Refactor', icon = '󰑌' },
	{ '<leader>rr', icon = '󰑌' },

	{ '<leader>u', icon = '󰄬' },

	{ '<leader>w', icon = '󰆓' },
	{ '<leader>q', icon = '󰈆' },
	{ '<leader>D', icon = '󰨮' },
	{ '<leader>/', icon = '󰤼' },
	{ '<leader>-', icon = '󰤻' },
})

-- Configure indent-blankline for better indentation visualization
require('ibl').setup({
	indent = {
		char = '│',
		tab_char = '│',
	},
	scope = {
		enabled = true,
		show_start = true,
		show_end = false,
		injected_languages = false,
		highlight = { 'Function', 'Label' },
		priority = 500,
	},
	exclude = {
		filetypes = {
			'help',
			'alpha',
			'dashboard',
			'neo-tree',
			'Trouble',
			'lazy',
			'mason',
			'notify',
			'toggleterm',
			'lazyterm',
		},
	},
})
require('obsidian').setup({
	dir = vim.env.HOME .. '/second-brain', -- specify the vault location. no need to call 'vim.fn.expand' here
	use_advanced_uri = true,
	finder = 'telescope.nvim',
	templates = {
		subdir = 'templates',
		date_format = '%Y-%m-%d-%a',
		time_format = '%H:%M',
	},
	note_frontmatter_func = function(note)
		-- This is equivalent to the default frontmatter function.
		local out = { id = note.id, aliases = note.aliases, tags = note.tags }
		-- `note.metadata` contains any manually added fields in the frontmatter.
		-- So here we just make sure those fields are kept in the frontmatter.
		if note.metadata ~= nil and require('obsidian').util.table_length(note.metadata) > 0 then
			for k, v in pairs(note.metadata) do
				out[k] = v
			end
		end
		return out
	end,
	ui = {
		enable = false,
	},
})

require('checkmate').setup({})

local servers = {
	-- clangd = {},
	-- gopls = {},
	-- pyright = {},
	-- rust_analyzer = {},
	-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
	--
	-- Some languages (like typescript) have entire language plugins that can be useful:
	--    https://github.com/pmizio/typescript-tools.nvim
	--
	tsserver = {
		cmd = { vim.fn.stdpath('data') .. '/mason/bin/typescript-language-server', '--stdio' },
	},
	svelte = {
		cmd = { vim.fn.stdpath('data') .. '/mason/bin/svelteserver', '--stdio' },
	},
	intelephense = {
		cmd = { vim.fn.stdpath('data') .. '/mason/bin/intelephense', '--stdio' },
	},
	['rust_analyzer'] = {
		diagnostics = {
			experimental = {
				enable = true, -- Sometimes fixes missing diagnostic metadata
			},
		},
	},

	lua_ls = {
		-- cmd = {...},
		-- filetypes = { ...},
		-- capabilities = {},
		settings = {
			Lua = {
				diagnostics = {
					enable = true,
					globals = { 'love', 'vim' },
					-- enable some extra strictness
					unusedLocal = 'Warning', -- warn on unused locals
					undefinedGlobal = 'Error', -- error on globals that don't exist
					undefinedField = 'Error', -- warn on fields not listed in @field
				},
				completion = {
					callSnippet = 'Replace',
				},
				telemetry = {
					enable = false,
				},
				-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
				-- diagnostics = { disable = { 'missing-fields' } },
			},
		},
	},
}
-- You can add other tools here that you want Mason to install
-- for you, so that they are available from within Neovim.
local ensure_installed = { 'lua_ls', 'rust_analyzer', 'svelte', 'intelephense' }

-- LSP servers and clients are able to communicate to each other what features they support.
--  By default, Neovim doesn't support everything that is in the LSP specification.
--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

-- Install on startup if there are any LSPs missing
vim.api.nvim_create_user_command('MasonInstallEnsured', function()
	local mason_packages = {
		'stylua',
		'intelephense',
		'svelte-language-server',
		'tailwindcss-language-server',
		'typescript-language-server',
		'write-good',
		'sqlls',
		'prettier',
		'emmet-ls',
		'json-lsp',
		'dockerfile-language-server',
		'docker-compose-language-service',
		'yaml-language-server',
		'markdownlint',
		'lua-language-server',
	}
	vim.cmd('MasonInstall ' .. table.concat(mason_packages, ' '))
end, {})

-- Ensure the servers and tools above are installed
--  To check the current status of installed tools and/or manually install
--  other tools, you can run
--    :Mason
--
--  You can press `g?` for help in this menu.
require('mason').setup()

local lspconfig = require('lspconfig')

require('mason-lspconfig').setup({
	ensure_installed = ensure_installed,
	handlers = {
		function(server_name)
			local server = servers[server_name] or {}
			server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
			lspconfig[server_name].setup(server)
		end,
	},
})

require('render-markdown').setup({
    heading = {
        -- Enable heading icon & background rendering
        enabled = true,
        -- Replace '#' markers with icons per heading level
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        -- Overlay icons over the '#' markers (concealed)
        position = 'overlay',
        -- Show heading icons in the sign column
        sign = true,
        signs = { '󰫎 ' },
        -- Background width: 'full' spans the window, 'block' wraps text
        width = { 'full', 'full', 'block', 'block', 'block', 'block' },
        -- Add border above/below h1 and h2
        border = { true, true, false, false, false, false },
        border_virtual = true,
        above = '▄',
        below = '▀',
        -- Margin/padding for visual breathing room
        left_margin = 0,
        left_pad = 1,
        right_pad = 1,
        -- Highlight group names per heading level
        backgrounds = {
            'RenderMarkdownH1Bg',
            'RenderMarkdownH2Bg',
            'RenderMarkdownH3Bg',
            'RenderMarkdownH4Bg',
            'RenderMarkdownH5Bg',
            'RenderMarkdownH6Bg',
        },
        foregrounds = {
            'RenderMarkdownH1',
            'RenderMarkdownH2',
            'RenderMarkdownH3',
            'RenderMarkdownH4',
            'RenderMarkdownH5',
            'RenderMarkdownH6',
        },
    },
    -- Enable anti-conceal: show concealed '#' markers on cursor line
    anti_conceal = {
        enabled = true,
    },
})
require('blame').setup({})

require('barbecue').setup({
	attach_navic = false, -- disable navic integration since we only want file path
	show_navic = true, -- don't show LSP context symbols
	show_dirname = true, -- show directory path
	show_basename = true, -- show file name
	context_follow_icon_color = true,
	kinds = false,     -- disable all kind icons/symbols
	modifiers = {
		dirname = ':~:.', -- show relative path from home and current directory
		basename = '', -- no modifiers for basename
	},
	symbols = {
		modified = '', -- no modified indicator
		ellipsis = '…', -- keep ellipsis for long paths
		separator = '/', -- use forward slash as separator
	},
	-- theme = {
	-- 	normal = { fg = '#C4B38A' },
	-- 	dirname = { fg = '#737aa2' },
	-- 	basename = { fg = '#C4B38A', bold = true },
	-- },
	custom_section = function()
		return '' -- empty custom section
	end,
	lead_custom_section = function()
		return '' -- empty leading section
	end,
})

-- Lualine setup
local kanagawa_paper = {
	bg = '#1F1F28',
	bg_dark = '#16161D',
	bg_alt = '#2A2A37',
	fg = '#DCD7BA',
	fg_dim = '#C8C093',
	muted = '#aca9a4',
	red = '#c4746e',
	green = '#699469',
	yellow = '#c4b28a',
	blue = '#809ba7',
	magenta = '#a292a3',
	cyan = '#8ea49e',
}

local kanagawa_paper_theme = {
	normal = {
		a = { fg = kanagawa_paper.bg_dark, bg = kanagawa_paper.cyan, gui = 'bold' },
		b = { fg = kanagawa_paper.fg, bg = kanagawa_paper.bg_alt },
		c = { fg = kanagawa_paper.fg_dim, bg = kanagawa_paper.bg },
	},
	insert = {
		a = { fg = kanagawa_paper.bg_dark, bg = kanagawa_paper.green, gui = 'bold' },
		b = { fg = kanagawa_paper.fg, bg = kanagawa_paper.bg_alt },
		c = { fg = kanagawa_paper.fg_dim, bg = kanagawa_paper.bg },
	},
	visual = {
		a = { fg = kanagawa_paper.bg_dark, bg = kanagawa_paper.magenta, gui = 'bold' },
		b = { fg = kanagawa_paper.fg, bg = kanagawa_paper.bg_alt },
		c = { fg = kanagawa_paper.fg_dim, bg = kanagawa_paper.bg },
	},
	replace = {
		a = { fg = kanagawa_paper.bg_dark, bg = kanagawa_paper.red, gui = 'bold' },
		b = { fg = kanagawa_paper.fg, bg = kanagawa_paper.bg_alt },
		c = { fg = kanagawa_paper.fg_dim, bg = kanagawa_paper.bg },
	},
	command = {
		a = { fg = kanagawa_paper.bg_dark, bg = kanagawa_paper.yellow, gui = 'bold' },
		b = { fg = kanagawa_paper.fg, bg = kanagawa_paper.bg_alt },
		c = { fg = kanagawa_paper.fg_dim, bg = kanagawa_paper.bg },
	},
	inactive = {
		a = { fg = kanagawa_paper.muted, bg = kanagawa_paper.bg_dark },
		b = { fg = kanagawa_paper.muted, bg = kanagawa_paper.bg_dark },
		c = { fg = kanagawa_paper.muted, bg = kanagawa_paper.bg_dark },
	},
}

local function filetype_with_icon()
	local icon, icon_color = require('nvim-web-devicons').get_icon_color_by_filetype(vim.bo.filetype)
	local filetype = vim.bo.filetype ~= '' and vim.bo.filetype or 'no ft'
	if icon then
		return icon .. ' ' .. filetype
	end
	return filetype
end

local function diagnostics_with_icons()
	local error_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local warn_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	local info_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
	local hint_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })

	local parts = {}
	if error_count > 0 then
		table.insert(parts, { ' ' .. error_count, 'DiagnosticError' })
	end
	if warn_count > 0 then
		table.insert(parts, { ' ' .. warn_count, 'DiagnosticWarn' })
	end
	if info_count > 0 then
		table.insert(parts, { ' ' .. info_count, 'DiagnosticInfo' })
	end
	if hint_count > 0 then
		table.insert(parts, { ' ' .. hint_count, 'DiagnosticHint' })
	end

	if #parts == 0 then
		return ''
	end

	local result = ''
	for i, part in ipairs(parts) do
		if i > 1 then
			result = result .. '  '
		end
		result = result .. '%#' .. part[2] .. '#' .. part[1] .. '%#Normal#'
	end
	return result
end

local function harpoon_display()
	local marks = harpoon:list().items
	local current_file_path = vim.fn.expand('%:p:.')
	local label = {}

	for id, item in ipairs(marks) do
		if item.value == current_file_path then
			table.insert(label, '%#HarpoonActive#' .. id .. '%#Normal#')
		else
			table.insert(label, '%#HarpoonInactive#' .. id .. '%#Normal#')
		end
	end

	if #label > 0 then
		return '󰛢 ' .. table.concat(label, ' ')
	end
	return ''
end

local function git_diff_display()
	local icons = { removed = ' ', changed = ' ', added = ' ' }
	local signs = vim.b.gitsigns_status_dict
	local labels = {}

	if signs == nil then
		return ''
	end

	for name, icon in pairs(icons) do
		if tonumber(signs[name]) and signs[name] > 0 then
			table.insert(labels, '%#Diff' .. name .. '#' .. icon .. signs[name] .. '%#Normal#')
		end
	end

	if #labels > 0 then
		return table.concat(labels, ' ')
	end
	return ''
end

require('lualine').setup({
	options = {
		theme = kanagawa_paper_theme,
		component_separators = { left = '│', right = '│' },
		section_separators = { left = '', right = '' },
		globalstatus = true,
		icons_enabled = true,
		disabled_filetypes = {
			statusline = { 'fyler' },
		},
	},
	sections = {
		lualine_a = {
			{
				'mode',
				fmt = function(str)
					return str:sub(1, 1)
				end,
			},
		},
		lualine_b = {
			{ 'branch', icon = '' },
			{ harpoon_display, color = {} },
		},
		lualine_c = {
			{ 'filename',             path = 1,  symbols = { modified = '', readonly = '', unnamed = '[No Name]' } },
			{ diagnostics_with_icons, color = {} },
			{ git_diff_display,       color = {} },
		},
		lualine_x = {
			{ filetype_with_icon, colored = false },
			{
				'encoding',
				fmt = function(str)
					return str ~= 'utf-8' and str or ''
				end,
			},
			{ 'fileformat',       symbols = { unix = '', dos = '', mac = '' } },
		},
		lualine_y = { 'progress' },
		lualine_z = { 'location' },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { 'filename' },
		lualine_x = { 'location' },
		lualine_y = {},
		lualine_z = {},
	},
})

-- -- Undercurl errors and warnings like in VSCode
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Copy path to clipboard
vim.api.nvim_create_user_command('Cppath', function()
	local path = vim.fn.expand('%:p')
	vim.fn.setreg('+', path)
	vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

-- Live markdown preview using Kitty's text sizing protocol (OSC 66).
-- Opens a vertical split that auto-refreshes as you edit. The preview renders
-- h1-h6 at proportionally larger font sizes (6x down to 2x base font).
-- Requires kitty >= 0.40.0. Close the preview window to stop auto-refresh.
vim.api.nvim_create_user_command('MarkdownPreview', function()
    local buf = vim.api.nvim_get_current_buf()
    local tmp = vim.fn.tempname() .. '.md'
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    vim.fn.writefile(lines, tmp)
    local script = vim.fn.expand('~/.dotfiles/scripts/kitty-markdown-live.py')
    local src_win = vim.api.nvim_get_current_win()

    -- Open terminal running the live preview watcher
    vim.cmd('belowright vsplit | terminal python3 -u ' .. script .. ' ' .. tmp)
    local preview_buf = vim.api.nvim_get_current_buf()
    local preview_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(src_win)

    -- Auto-refresh preview on each text change
    local augroup = vim.api.nvim_create_augroup('MarkdownPreview' .. buf, { clear = true })
    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufWritePost' }, {
        group = augroup,
        buffer = buf,
        callback = function()
            if vim.api.nvim_win_is_valid(preview_win) then
                local updated = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                vim.fn.writefile(updated, tmp)
            else
                -- Preview window was closed — clean up
                vim.api.nvim_del_augroup_by_id(augroup)
                pcall(vim.fn.delete, tmp)
            end
        end,
    })

    -- Clean up temp file when preview buffer is closed
    vim.api.nvim_create_autocmd('BufWipeout', {
        buffer = preview_buf,
        once = true,
        callback = function()
            vim.api.nvim_del_augroup_by_id(augroup)
            pcall(vim.fn.delete, tmp)
        end,
    })
end, { desc = 'Live markdown preview with variable font sizes (Kitty OSC 66)' })

require('cyberdream').setup({
	-- Set light or dark variant
	variant = 'default', -- use "light" for the light variant. Also accepts "auto" to set dark or light colors based on the current value of `vim.o.background`

	-- Enable transparent background
	transparent = false,

	-- Reduce the overall saturation of colours for a more muted look
	saturation = 1, -- accepts a value between 0 and 1. 0 will be fully desaturated (greyscale) and 1 will be the full color (default)

	-- Enable italics comments
	italic_comments = false,

	-- Replace all fillchars with ' ' for the ultimate clean look
	hide_fillchars = false,

	-- Apply a modern borderless look to pickers like Telescope, Snacks Picker & Fzf-Lua
	borderless_pickers = false,

	-- Set terminal colors used in `:terminal`
	terminal_colors = true,

	-- Improve start up time by caching highlights. Generate cache with :CyberdreamBuildCache and clear with :CyberdreamClearCache
	cache = false,

	-- Override highlight groups with your own colour values
	highlights = {
		-- Highlight groups to override, adding new groups is also possible
		-- See `:h highlight-groups` for a list of highlight groups or run `:hi` to see all groups and their current values

		-- Example:
		Comment = { fg = '#696969', bg = 'NONE', italic = true },

		-- More examples can be found in `lua/cyberdream/extensions/*.lua`
	},

	-- Override a highlight group entirely using the built-in colour palette
	overrides = function(colors) -- NOTE: This function nullifies the `highlights` option
		-- Example:
		return {
			Comment = { fg = colors.green, bg = 'NONE', italic = true },
			['@property'] = { fg = colors.magenta, bold = true },
		}
	end,

	-- Override colors
	colors = {
		-- For a list of colors see `lua/cyberdream/colours.lua`

		-- Override colors for both light and dark variants
		bg = '#000000',
		green = '#00ff00',

		-- If you want to override colors for light or dark variants only, use the following format:
		dark = {
			magenta = '#ff00ff',
			fg = '#eeeeee',
		},
		light = {
			red = '#ff5c57',
			cyan = '#5ef1ff',
		},
	},

	-- Disable or enable colorscheme extensions
	extensions = {
		telescope = true,
		notify = true,
		mini = true,
		...,
	},

	-- Alternatively, you can use 'default' to set all extensions at once
	-- cache = true, -- Use cache for fastest loads
	-- extensions = {
	--     default = false, -- Disable all by default
	--     base = true, -- Enable all built-in hl groups (you probably want this)
	--
	--     -- Now enable only what you want to use
	--     telescope = true,
	--     cmp = true,
	--     gitsigns = true,
	-- },
})

require('vesper').setup({
	transparent = true, -- Boolean: Sets the background to transparent
	italics = {
		comments = false, -- Boolean: Italicizes comments
		keywords = false, -- Boolean: Italicizes keywords
		functions = false, -- Boolean: Italicizes functions
		strings = false, -- Boolean: Italicizes strings
		variables = false, -- Boolean: Italicizes variables
	},
	overrides = {},  -- A dictionary of group names, can be a function returning a dictionary or a table.
	palette_overrides = {},
})

require('ember').setup({
	variant = 'ember', -- 'ember', 'ember-soft', 'ember-light', 'ember-auto'
	styles = {
		variables = { italic = false, bold = false },
		comments = { italic = false, bold = false },
		keywords = { italic = false, bold = false },
		functions = { italic = false, bold = false },
		types = { italic = false, bold = false },
	},
	transparent = false,        -- transparent editor background
	transparent_floats = nil,   -- follows `transparent` by default; set explicitly to override
	dark_variant = 'ember',     -- used by `ember-auto` when background = 'dark'
	light_variant = 'ember-light', -- used by `ember-auto` when background = 'light'
	on_colors = nil,            -- function(palette) - modify palette before theme builds
	on_highlights = function(highlights)
		for _, highlight in pairs(highlights) do
			if type(highlight) == 'table' then
				highlight.italic = false
				highlight.bold = false
			end
		end
	end,
})

vim.cmd(':hi statusline guibg=NONE')
apply_terminal_theme_highlights()

-- Set colorscheme
vim.cmd('colorscheme kanagawa-paper-ink')
-- vim.cmd('colorscheme ember')
-- vim.cmd('colorscheme cyberdream')
-- vim.cmd('colorscheme vscode')
-- vim.cmd('colorscheme catppuccin-frappe')
-- vim.cmd('colorscheme catppuccin-mocha')
-- vim.cmd('colorscheme catppuccin-latte')
-- vim.cmd('colorscheme rose-pine')
-- vim.cmd('colorscheme mhfu-pokke')
-- vim.cmd('colorscheme vague')
vim.cmd(':hi statusline guibg=NONE')

-- =============================================================================
-- MARKDOWN HEADING HIGHLIGHTS (render-markdown.nvim)
-- =============================================================================
-- These highlight groups give headings visual hierarchy through backgrounds,
-- underlines, and bold styling — compensating for the terminal's lack of
-- per-cell font sizes (Kitty's text sizing protocol can't be used inline by
-- Neovim's TUI). The :MarkdownPreview command (below) uses Kitty's OSC 66
-- protocol to actually render headings at larger font sizes.

-- Heading foregrounds: bold + bright per level
vim.api.nvim_set_hl(0, 'RenderMarkdownH1', { fg = '#DCD7BA', bold = true })
vim.api.nvim_set_hl(0, 'RenderMarkdownH2', { fg = '#DCD7BA', bold = true })
vim.api.nvim_set_hl(0, 'RenderMarkdownH3', { fg = '#E6C384', bold = true })
vim.api.nvim_set_hl(0, 'RenderMarkdownH4', { fg = '#E6C384', bold = false })
vim.api.nvim_set_hl(0, 'RenderMarkdownH5', { fg = '#C0A36E', bold = false })
vim.api.nvim_set_hl(0, 'RenderMarkdownH6', { fg = '#C0A36E', bold = false })

-- Heading backgrounds: subtle tint, strongest for h1-h2
vim.api.nvim_set_hl(0, 'RenderMarkdownH1Bg', { bg = '#1F1F28' })
vim.api.nvim_set_hl(0, 'RenderMarkdownH2Bg', { bg = '#1F1F28' })
vim.api.nvim_set_hl(0, 'RenderMarkdownH3Bg', { bg = '#1A1A22' })
vim.api.nvim_set_hl(0, 'RenderMarkdownH4Bg', { bg = '#1A1A22' })
vim.api.nvim_set_hl(0, 'RenderMarkdownH5Bg', { bg = '#16161D' })
vim.api.nvim_set_hl(0, 'RenderMarkdownH6Bg', { bg = '#16161D' })
