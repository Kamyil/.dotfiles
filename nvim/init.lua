-- THIS CONFIG REQUIRED NVIM v0.12.0 to work, since we need Neovim's Native package manager (we're not using Lazy.nvim anymore for plugins)

-- OPTIONS -- (boring but important stuff)
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = 'yes'
vim.o.termguicolors = true -- Enable nice colors
vim.o.wrap = false -- Disable line wrap
vim.o.tabstop = 4 -- set Tabs as default (where Tab = 4 Spaces here)
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> counts for while performing editing operations
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = false -- Use tabs instead of spaces
vim.o.swapfile = false -- it's annoying when saving, and opening project back again, so turning that off
vim.g.mapleader = ' ' -- Map leader to Space key
vim.g.maplocalleader = ' ' -- Sets the local leader key to <space>
vim.o.winborder = 'rounded'
vim.o.clipboard = 'unnamedplus' -- For Windows it's gonna be different
vim.g.have_nerd_font = true -- Enables Nerd Font support for icons
vim.o.encoding = 'utf-8' -- Sets the internal encoding
vim.o.fileencoding = 'utf-8' -- Sets the encoding for the current file
vim.o.fileencodings = 'utf-8' -- Sets the list of encodings to try when reading a file
vim.opt.laststatus = 0 -- 0: Never, 1: Only if there are at least two windows, 2: Always, 3: Global statusline
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir' -- Directory to store undo history
vim.opt.undofile = true -- Enable persistent undo
vim.opt.updatetime = 100 -- Time in milliseconds to wait before triggering the swap/undo file write (default 4000)
vim.opt.incsearch = true -- Show search matches as you type
vim.opt.mouse = 'a' -- Enable mouse support in all modes
vim.opt.breakindent = true -- Enable break indent (preserves indentation in wrapped lines)
vim.opt.timeoutlen = 200 -- Time in ms to wait for a mapped sequence to complete
-- Enable settings per project
vim.g.editorconfig = true -- Enable EditorConfig support
-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 8 -- Keep 8 lines visible above/below the cursor
vim.opt.ruler = false -- Don't show the ruler (line/column info)
vim.opt.sidescrolloff = 8 -- Keep 8 columns visible to the left/right of the cursor
-- Enable icons (`nvim-tree/nvim-web-devicons` plugin in this case)
vim.g.icons_enabled = true -- Enable icons in plugins
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- Characters to use for displaying whitespace
vim.opt.list = true -- Do not show whitespace characters by default
vim.opt.fillchars = { eob = ' ' } -- Change the character at the end of buffer (empty lines)
vim.g.loaded_netrw = 1 -- disable netrw (default file explorer)
vim.g.loaded_netrwPlugin = 1 --  disable netrw plugin
vim.opt.conceallevel = 0 -- so that `` is visible in markdown files
vim.opt.ignorecase = true -- ignore case in search patterns (again, for redundancy)
vim.opt.smartcase = true -- smart case (again, for redundancy)
vim.opt.smartindent = true -- make indenting smarter again

-- Undercurl errors and warnings like in VSCode
vim.cmd([[let &t_Cs = "\e[4:3m"]]) -- Enable undercurl for errors
vim.cmd([[let &t_Ce = "\e[4:0m"]]) -- Disable undercurl

-- Toggle spell check
vim.opt.spell = false                    -- Disable spell checking by default
vim.opt.spelllang = { 'en_us', 'pl_PL' } -- Set spell check languages

vim.opt.winborder = 'single'             -- Set window border style to single line
vim.g.autoformat = false                 -- Disable autoformatting by default

-- Enable default LSP inline diagnostic
vim.diagnostic.config({
	virtual_text = false,                       -- Ensure virtual text is disabled since lsp_lines handles it
	virtual_lines = { only_current_line = false }, -- Show virtual lines for all lines
	signs = true,                               -- Show signs in the sign column
	underline = true,                           -- Underline diagnostics
	update_in_insert = true,                    -- Don't update diagnostics in insert mode
	severity_sort = true,                       -- Sort diagnostics by severity
})
--

-- # KEYMAPS #
-- Helper function for defining key mappings / key shortcuts
-- @field mode - 'n' for normal, 'v' for visual, 'i' for insert, 'x' for all
-- @field keys - keys themselves where "C-" means Ctrl+, "A-" means "Alt+", "<leader>+" means Space+
-- @field callback - command or function to execute
local keymap = vim.keymap.set

keymap('n', '<leader>o', ':update<CR> :source<CR>') -- source file inline (most useful for editing neovim config file
keymap('n', '<leader>w', ':write<CR>')
keymap('n', '<leader>q', ':quit<CR>')
--

-- Get the plugins and install them
vim.pack.add({
	-- DEPENDENCIES --
	{ src = 'https://github.com/nvim-lua/plenary.nvim' },     -- Dependency of most plugins below
	{ src = 'https://github.com/rafamadriz/friendly-snippets' }, -- Dependency of blink.cmp

	-- Misc --
	{ src = 'https://github.com/nvim-tree/nvim-web-devicons' }, -- Icons
	{ src = 'https://github.com/chentoast/marks.nvim' },     -- Show marks next to line number if there is one (and make them last when quitting Neovim)

	-- Colorscheme / theme --
	{ src = 'https://github.com/sho-87/kanagawa-paper.nvim' },

	{ src = 'https://github.com/b0o/incline.nvim' },             -- For showing current file and extra data about it

	{ src = 'https://github.com/stevearc/oil.nvim' },            -- File managment like Vim buffer (hit <leader>+e)
	{ src = 'https://github.com/echasnovski/mini.pick' },        -- Simple quick file picker
	{ src = 'https://github.com/nvim-treesitter/nvim-treesitter' }, -- Tresitter (for coloring syntax and doing AST-based operations)
	{ src = 'https://github.com/alexghergh/nvim-tmux-navigation' }, -- Better navigation with TMUX (can move between nvim and tmux splits with same motions)
	{ src = 'https://github.com/Saghen/blink.cmp' },             -- Better autocompletion
	{ src = 'https://github.com/folke/lazydev.nvim' },           -- Better neovim config editing, without any non-valid warnings
	{ src = "https://github.com/neovim/nvim-lspconfig" },        -- Baked-in, ready-to-use LSP configs to not configure them manually
	{ src = 'https://github.com/folke/todo-comments.nvim' },     -- Highlight comments like TODO, FIXME, BUG, INFO etc.

	-- Git
	{ src = 'https://github.com/kdheepak/lazygit.nvim' },

	-- Harpoon
	{ src = 'https://github.com/ThePrimeagen/harpoon',           version = 'harpoon2' }, -- For better file managment
	{ src = 'https://github.com/kiennt63/harpoon-files.nvim' },             -- ^ for showing the current harpoon indexes
})

-- Setup native LSP handler
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})
vim.cmd('set completeopt+=noselect')

require('mini.pick').setup()

-- Setup syntax color highlighting (+ more AST-based operations)
require('nvim-treesitter.configs').setup({
	ensure_installed = { 'svelte', 'typescript', 'javascript', 'php' },
	highlight = { enable = true },
})

require('oil').setup() -- Setup file manager (that allows editing files like normal Vim buffer)

-- Pickers
keymap('n', '<leader>ff', ':Pick files<CR>')
keymap('n', '<leader>fw', ':Pick grep_live<CR>')
keymap('n', '<leader>fh', ':Pick help<CR>')
keymap('n', '<leader>e', ':Oil<CR>')
-- LSP
keymap('n', '<leader>la', vim.lsp.buf.code_action)
keymap('n', '<leader>lf', vim.lsp.buf.format)
keymap('n', '<leader>lr', vim.lsp.buf.rename)
keymap('n', 'K', vim.lsp.buf.hover)
keymap('n', '<leader>g', ':LazyGit<CR>')

vim.lsp.enable({
	'lua_ls',
	'svelte',
	'tailwindcss',
	'javascript',
	'typescript-language-server',
	'dockerls',
	'docker_compose_language_service',
	'emmylua_ls', --  Luadocs for typesafety and autocompletion
	'emmet_ls', -- HTML quick actions & snippets
	'html',     -- HTML
	'jsonls',   -- JSON
	'just',     -- Justfile
	'intelephense' -- PHP
})

local nvim_tmux_nav = require('nvim-tmux-navigation')
nvim_tmux_nav.setup({
	disable_when_zoomed = false,
	keybindings = {
		left = "<C-h>",
		down = "<C-j>",
		up = "<C-k>",
		right = "<C-l>",
		last_active = "<C-\\>",
		next = "<C-Space>",
	}
})


-- Harpoon setup (quick file switching between files that I currently work on)
local harpoon = require('harpoon')
-- local harpoon_mark = require('harpoon.mark');

harpoon:setup()

keymap('n', '<A-a>', function() harpoon:list():add() end) -- add file to harpoon list
keymap('n', '<A-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

keymap('n', '<A-1>', function() harpoon:list():select(1) end) -- navigate to file 1
keymap('n', '<A-2>', function() harpoon:list():select(2) end) -- navigate to file 2
keymap('n', '<A-3>', function() harpoon:list():select(3) end) -- navigate to file 3
keymap('n', '<A-4>', function() harpoon:list():select(4) end) -- navigate to file 4
keymap('n', '<A-5>', function() harpoon:list():select(5) end) -- navigate to file 5
keymap('n', '<A-6>', function() harpoon:list():select(6) end) -- navigate to file 6
keymap('n', '<A-7>', function() harpoon:list():select(7) end) -- navigate to file 7
keymap('n', '<A-8>', function() harpoon:list():select(8) end) -- navigate to file 8
keymap('n', '<A-9>', function() harpoon:list():select(9) end) -- navigate to file 9
--
-- better indenting with selected text
keymap('v', '<', '<gv')
keymap('v', '>', '>gv')

-- Paste by Replacing contents with clipboard content (without replacing what's already in register, so 'paste and keep it still')
keymap('v', '<leader>p', [["_dP]])

-- Move to next items inside quickfix list
keymap('n', ']q', '<cmd>cnext<CR>zz')
keymap('n', '[q', '<cmd>cprev<CR>zz')

keymap('n', '|', '<cmd>vsplit<CR>')
keymap('n', '_', '<cmd>split<CR>')

-- Best remap ever - move selected lines up and down without leaving the selection
keymap('v', 'J', ":m '>+1<CR>gv=gv")
keymap('v', 'K', ":m '<-2<CR>gv=gv")


require('kanagawa-paper').setup({
	transparent = true,
	undercurl = true,
	diag_background = true,
	terminal_colors = true
})
require('marks').setup()
-- require('blink').setup() -- TODO: Fix

vim.cmd('colorscheme kanagawa-paper')
vim.cmd(':hi statusline guibg=NONE')

-- Autocommands
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
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


-- Disable Tree-sitter for buffers larger than MAX_FILESIZE in order to not lag the Neovim
vim.api.nvim_create_autocmd('BufReadPre', {
	pattern = '*',
	callback = function()
		local MAX_FILESIZE = 1000000 -- 1MB
		local filepath = vim.fn.expand('<afile>')
		local ok, stats = pcall(vim.loop.fs_stat, filepath)

		if ok and stats and stats.size > MAX_FILESIZE then
			-- Temporarily disable Tree-sitter and syntax highlighting
			vim.cmd('TSBufDisable highlight')
			vim.cmd('syntax off')
		end
	end,
})


require('todo-comments')
require('incline').setup({
	window = {
		placement = {
			vertical = 'bottom',
			horizontal = 'center',
		},
		padding = 0,
		margin = { vertical = 2, horizontal = 2 },
	},
	hide = {
		cursorline = true,
	},
	render = function(props)
		local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
		if filename == '' then
			filename = '[No Name]'
		end
		local filetype_icon, filetype_color = require('nvim-web-devicons').get_icon_color(filename)

		local function get_git_diff()
			local icons = { removed = ' ', changed = ' ', added = ' ' }
			local signs = vim.b[props.buf].gitsigns_status_dict
			local labels = {}
			if signs == nil then
				return labels
			end
			for name, icon in pairs(icons) do
				if tonumber(signs[name]) and signs[name] > 0 then
					table.insert(labels, { icon .. signs[name] .. ' ', group = 'Diff' .. name })
				end
			end
			if #labels > 0 then
				table.insert(labels, { '| ' })
			end
			return labels
		end

		local function get_diagnostic_label()
			local icons = { error = ' ', warn = ' ', info = ' ', hint = ' ' }
			local label = {}

			for severity, icon in pairs(icons) do
				local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
				if n > 0 then
					table.insert(label, { icon .. n .. ' ', group = 'DiagnosticSign' .. severity })
				end
			end
			if #label > 0 then
				table.insert(label, { '| ' })
			end
			return label
		end

		local function get_harpoon_items()
			local marks = harpoon:list().items
			local current_file_path = vim.fn.expand('%:p:.')
			local label = {}

			for id, item in ipairs(marks) do
				if item.value == current_file_path then
					table.insert(label, { id .. ' ', guifg = '#C4B38A', gui = 'bold' })
				else
					table.insert(label, { id .. ' ', guifg = '#434852' })
				end
			end

			if #label > 0 then
				table.insert(label, 1, { '󰛢 ', guifg = '#C4B38A' })
				-- table.insert(label, 1, { ' ', guifg = '#C4B38A' })
				table.insert(label, { '| ' })
			end
			return label
		end

		local function get_file_name()
			local label = {}
			table.insert(label, { (filetype_icon or '') .. ' ', guifg = filetype_color, guibg = 'none' })
			table.insert(label, { vim.bo[props.buf].modified and ' ' or '', guifg = '#d19a66' })
			table.insert(label,
				{ filename, gui = vim.bo[props.buf].modified and 'bold,italic' or 'bold', guifg = '#C4B38A' })

			if not props.focused then
				label['group'] = 'BufferInactive'
			end

			return label
		end

		return {
			{ ' ', guifg = '#201F27', guibg = '#201F27' },
			{
				{ get_harpoon_items() },
				{ ' ',                   guifg = '#201F27', guibg = '#201F27' },
				{ get_file_name() },
				{ ' ',                   guifg = '#201F27', guibg = '#201F27' },
				{ get_diagnostic_label() },
				{ ' ',                   guifg = '#201F27', guibg = '#201F27' },
				{ get_git_diff() },
				guibg = '#201F27',
			},
			{ ' ', guifg = '#201F27', guibg = '#201F27' },
		}
	end,
})
