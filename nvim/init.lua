-- THIS CONFIG REQUIRES NVIM v0.12.0 to work, since we need Neovim's Native package manager
-- (we're not using Lazy.nvim anymore for plugins, although I'm still not sure if it's a good thing. We'll see)

-- OPTIONS -- (boring but important stuff)
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = 'yes' -- will use 3 columns to make line numbers have a little bit more margin
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
-- -- Undercurl errors and warnings like in VSCode
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Toggle spell check
vim.opt.spell = false                    -- Disable spell checking by default
vim.opt.spelllang = { 'en_us', 'pl_PL' } -- Set spell check languages

vim.opt.winborder = 'single'             -- Set window border style to single line
vim.g.autoformat = false                 -- Disable autoformatting by default

-- Enable default LSP inline diagnostic
vim.diagnostic.config({
	-- virtual_text = false,                       -- Ensure virtual text is disabled since lsp_lines handles it
	-- virtual_lines = { only_current_line = false }, -- Show virtual lines for all lines
	-- underline = true,                           -- Underline diagnostics
	severity_sort = true, -- Sort diagnostics by severity
	underline = true,
	virtual_text = {
		spacing = 2,
		prefix = "●",
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
	}
})
--


-- Get the plugins and install them
vim.pack.add({
	-- DEPENDENCIES --
	{ src = 'https://github.com/nvim-lua/plenary.nvim' },        -- Dependency of most plugins below
	{ src = 'https://github.com/rafamadriz/friendly-snippets' }, -- Dependency of blink.cmp


	-- LSP
	{ src = 'https://github.com/mason-org/mason.nvim' },              -- LSPs & Formatters installer
	{ src = "https://github.com/neovim/nvim-lspconfig" },             -- Baked-in, ready-to-use LSP configs to not configure them manually
	{ src = 'https://github.com/williamboman/mason-lspconfig.nvim' }, -- Configs
	{ src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },


	-- Misc --
	{ src = 'https://github.com/nvim-tree/nvim-web-devicons' }, -- Icons
	{ src = 'https://github.com/chentoast/marks.nvim' },        -- Show marks next to line number if there is one (and make them last when quitting Neovim)
	{ src = 'https://github.com/folke/which-key.nvim' },        -- Shows available shortcuts when hitting <leader> or some motion
	{ src = 'https://github.com/windwp/nvim-autopairs' },       -- Autopair brackets, strings etc.
	{
		src = 'https://github.com/Saghen/blink.cmp',
		version = '1.*'
	},                                                                  -- Better Autocompletion
	{ src = "https://github.com/zbirenbaum/copilot.lua" },
	{ src = "https://github.com/giuxtaposition/blink-cmp-copilot" },    -- Copilot for Blink.cmp autocompletion

	{ src = 'https://github.com/lukas-reineke/indent-blankline.nvim' }, -- Add indentation guides even on blank lines
	{ src = "https://github.com/farmergreg/vim-lastplace" },            --  Automatically jump to the last cursor position
	{ src = "https://github.com/tpope/vim-sleuth" },                    -- Detect tabstop and shiftwidth automatically

	{ src = 'https://github.com/sho-87/kanagawa-paper.nvim' },          -- Colorscheme / theme --

	{ src = 'https://github.com/b0o/incline.nvim' },                    -- For showing current file and extra data about it

	{ src = 'https://github.com/stevearc/oil.nvim' },                   -- File managment like Vim buffer (hit <leader>+e)
	{ src = 'https://github.com/ibhagwan/fzf-lua' },                    -- Fastest file/grep picker I've found so far
	{ src = 'https://github.com/echasnovski/mini.surround' },           -- Allows to surround selected text with brackets, quotes, tags etc.
	{ src = 'https://github.com/nvim-treesitter/nvim-treesitter' },     -- Tresitter (for coloring syntax and doing AST-based operations)
	{ src = 'https://github.com/alexghergh/nvim-tmux-navigation' },     -- Better navigation with TMUX (can move between nvim and tmux splits with same motions)
	{ src = 'https://github.com/folke/lazydev.nvim' },                  -- Better neovim config editing, without any non-valid warnings
	{ src = 'https://github.com/folke/todo-comments.nvim' },            -- Highlight comments like TODO, FIXME, BUG, INFO etc.
	{ src = "https://github.com/mluders/comfy-line-numbers.nvim" },     -- More comfortable vertical motions (without needing to reach so far away from current buttons)
	{ src = 'https://github.com/brenoprata10/nvim-highlight-colors' },  -- Highlight color codes

	-- Git
	{ src = 'https://github.com/kdheepak/lazygit.nvim' },     -- Lazygit inside Neovim
	{ src = 'https://github.com/akinsho/git-conflict.nvim' }, -- Coloring Git Conflict inline

	-- Harpoon
	{ -- For better switching between files. Add files to the jumplist and switch between them with Alt+1,2,3,4,5. Also edit jumplist like a vim buffer
		src = 'https://github.com/ThePrimeagen/harpoon',
		version = 'harpoon2'
	},
	{ src = 'https://github.com/kiennt63/harpoon-files.nvim' }, -- ^ for showing the current harpoon indexes inside incline (that shows current file)

	-- Markdown notetaking
	{ src = 'https://github.com/epwalsh/obsidian.nvim' },
	{ src = 'https://github.com/bullets-vim/bullets.vim' },
	{ src = 'https://github.com/OXY2DEV/markview.nvim' }
})

-- -- Setup native LSP handler
-- vim.api.nvim_create_autocmd('LspAttach', {
-- 	callback = function(ev)
-- 		local client = vim.lsp.get_client_by_id(ev.data.client_id)
-- 		if client:supports_method('textDocument/completion') then
-- 			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
-- 		end
-- 	end,
-- })
--
-- vim.cmd('set completeopt+=noselect')
--

-- Setup syntax color highlighting (+ more AST-based operations)
require('nvim-treesitter.configs').setup({
	ensure_installed = { 'svelte', 'typescript', 'javascript', 'php' },
	highlight = { enable = true },
})

-- # KEYMAPS #
-- Helper function for defining key mappings / key shortcuts
-- @field mode - 'n' for normal, 'v' for visual, 'i' for insert, 'x' for all
-- @field keys - keys themselves where "C-" means Ctrl+, "A-" means "Alt+", "<leader>+" means Space+
-- @field callback - command or function to execute
-- @field options - some extra options as Lua table
-- @field options.desc - Description of a keymap, that will be displayed in which-key
local keymap = vim.keymap.set


require('fzf-lua').setup({
	-- Load the 'ivy' profile first
	'telescope',
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
keymap('n', '<leader>ff', fzf_lua.files)
keymap('n', '<leader>fw', fzf_lua.live_grep_native)
-- keymap('n', '<leader>fh', ':Pick help<CR>')
keymap('n', '<leader>e', ':Oil<CR>', { desc = 'File [E]xplorer' })
-- LSP
keymap('n', '<leader>la', vim.lsp.buf.code_action, { desc = '' })
keymap('n', '<leader>lf', vim.lsp.buf.format)
keymap('n', '<leader>lr', vim.lsp.buf.rename)
keymap('n', 'K', vim.lsp.buf.hover)
keymap('n', '<leader>g', ':LazyGit<CR>')

require('git-conflict')
keymap('n', '<leader>gb', '<cmd>BlameToggle window<CR>', { desc = '[G]it [Blame]' })
keymap('n', '<leader>gcc', '<cmd>GitConflictChooseOurs<CR>', { desc = '[G]it [C]onflict Choose [C]urrent' })
keymap('n', '<leader>gci', '<cmd>GitConflictChooseTheirs<CR>', { desc = '[G]it [C]onflict Choose [I]ncoming' })
keymap('n', '<leader>gcb', '<cmd>GitConflictChooseBoth<CR>', { desc = '[G]it [Conflict] Choose [B]oth' })
keymap('n', '<leader>gcn', '<cmd>GitConflictChooseOurs<CR>', { desc = '[G]it [Conflict] Choose [N]one' })
keymap('n', '<leader>gc[', '<cmd>GitConflictChooseOurs<CR>', { desc = '[G]it [Conflict] Previous' })
keymap('n', '<leader>gc]', '<cmd>GitConflictChooseOurs<CR>', { desc = '[G]it [Conflict] Next' })


-- LSPs
-- vim.lsp.enable({
-- 	'lua_ls',
-- 	'svelte',
-- 	'tailwindcss',
-- 	'javascript',
-- 	'ts_ls',
-- 	'dockerls',
-- 	'docker_compose_language_service',
-- 	'emmylua_ls', --  Luadocs for typesafety and autocompletion
-- 	'emmet_ls', -- HTML quick actions & snippets
-- 	'html',     -- HTML
-- 	'jsonls',   -- JSON
-- 	'just',     -- Justfile
-- 	'intelephense' -- PHP
-- }o

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

keymap('n', '<leader>o', ':update<CR> :source<CR>') -- source file inline (most useful for editing neovim config file
keymap('n', '<leader>w', ':write<CR>')
keymap('n', '<leader>q', ':quit<CR>')

-- Harpoon setup (quick file switching between files that I currently work on)
local harpoon = require('harpoon')
-- local harpoon_mark = require('harpoon.mark');

harpoon:setup()

keymap('n', '<A-a>', function() harpoon:list():add() end)                         -- add file to harpoon jumplist
keymap('n', '<A-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end) -- open jumplist with currently added items

keymap('n', '<A-1>', function() harpoon:list():select(1) end)                     -- navigate to file 1 in jumplist
keymap('n', '<A-2>', function() harpoon:list():select(2) end)                     -- navigate to file 2 in jumplist
keymap('n', '<A-3>', function() harpoon:list():select(3) end)                     -- navigate to file 3 in jumplist
keymap('n', '<A-4>', function() harpoon:list():select(4) end)                     -- navigate to file 4 in jumplist
keymap('n', '<A-5>', function() harpoon:list():select(5) end)                     -- navigate to file 5 in jumplist
keymap('n', '<A-6>', function() harpoon:list():select(6) end)                     -- navigate to file 6 in jumplist
keymap('n', '<A-7>', function() harpoon:list():select(7) end)                     -- navigate to file 7 in jumplist
keymap('n', '<A-8>', function() harpoon:list():select(8) end)                     -- navigate to file 8 in jumplist
keymap('n', '<A-9>', function() harpoon:list():select(9) end)                     -- navigate to file 9 in jumplist
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

-- Best remap ever - move selected lines up and down without leaving the selection, a.k.a move code around
keymap('v', 'J', ":m '>+1<CR>gv=gv")
keymap('v', 'K', ":m '<-2<CR>gv=gv")

-- Make backspace work as black hole cut
keymap("n", "<backspace>", '"_dh', { noremap = true })
keymap("v", "<backspace>", '"_d', { noremap = true })


-- Select all with Ctrl+A
keymap("n", "<C-a>", "ggVG")

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
		ink = { brightness = 0, saturation = 0 },
		canvas = { brightness = 0, saturation = 0 },
	},

	auto_plugins = true,
})
-- Kanagawa theme override: Override Svelte tag colors, to make them distinct
vim.schedule(function()
	vim.api.nvim_set_hl(0, '@tag.svelte', { fg = '#8EA4A2', bold = false })
	vim.api.nvim_set_hl(0, '@tag.attribute.svelte', { fg = '#B98D7B', bold = false })
end)
require('oil').setup() -- Setup file manager (that allows editing files like normal Vim buffer)
-- require('mini.pick').setup()
--
require('mini.surround').setup()
require('marks').setup()
require('nvim-autopairs').setup()

require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
})
require('blink.cmp').setup({ -- setup autocompletion
	preset = 'enter',
	fuzzy = {
		implementation = 'prefer_rust',
		prebuilt_binaries = {
			force_version = '1.*.*'
		}
	},
	completion = {
		menu = {
			draw = {
				components = {
					-- customize the drawing of kind icons
					kind_icon = {
						text = function(ctx)
							-- default kind icon
							local icon = ctx.kind_icon
							-- if LSP source, check for color derived from documentation
							if ctx.item.source_name == "LSP" then
								local color_item = require("nvim-highlight-colors").format(ctx.item.documentation,
									{ kind = ctx.kind })
								if color_item and color_item.abbr ~= "" then
									icon = color_item.abbr
								end
							end
							return icon .. ctx.icon_gap
						end,
						highlight = function(ctx)
							-- default highlight group
							local highlight = "BlinkCmpKind" .. ctx.kind
							-- if LSP source, check for color derived from documentation
							if ctx.item.source_name == "LSP" then
								local color_item = require("nvim-highlight-colors").format(ctx.item.documentation,
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
		},
		list = {
			selection = { preselect = false, auto_insert = true },
		},
	},
	signature = { enabled = true },
	sources = {
		default = { "lsp", "path", "snippets", "buffer", "copilot" },
		providers = {
			copilot = {
				name = "copilot",
				module = "blink-cmp-copilot",
				score_offset = 100,
				async = true,
			},
		},
		per_filetype = {
			codecompanion = { "codecompanion" },
		},
	},
})

vim.cmd('colorscheme kanagawa-paper-ink')
vim.cmd(':hi statusline guibg=NONE')

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
		if vim.fn.line("'\"") > 0 then
			vim.cmd('normal! g`"')
		end
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

require('comfy-line-numbers').setup({
	-- labels = {
	-- 	'1', '2', '3', '4', '5', '11', '12', '13', '14', '15', '21', '22', '23',
	-- 	'24', '25', '31', '32', '33', '34', '35', '41', '42', '43', '44', '45',
	-- 	'51', '52', '53', '54', '55', '111', '112', '113', '114', '115', '121',
	-- 	'122', '123', '124', '125', '131', '132', '133', '134', '135', '141',
	-- 	'142', '143', '144', '145', '151', '152', '153', '154', '155', '211',
	-- 	'212', '213', '214', '215', '221', '222', '223', '224', '225', '231',
	-- 	'232', '233', '234', '235', '241', '242', '243', '244', '245', '251',
	-- 	'252', '253', '254', '255',
	-- },
	down_key = 'j',
	up_key = 'k',

	-- Line numbers will be completely hidden for the following file/buffer types
	hidden_file_types = { 'help', 'TelescopePrompt', 'oil', 'markdown', 'markdown.mdx', 'undotree' },
	hidden_buffer_types = { 'terminal', 'blink', 'cmp' }
})
require('todo-comments').setup()
require('nvim-highlight-colors').setup({})
require('which-key').setup({ preset = 'helix' })
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
}
)
require('incline').setup({
	window = {
		placement = {
			vertical = 'bottom',
			horizontal = 'center',

		},
		padding = 0,
		margin = { vertical = 0, horizontal = 0 },
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
	-- But for many setups, the LSP (`ts_ls`) will work just fine
	-- ts_ls = {},
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
					unusedLocal = 'Warning',   -- warn on unused locals
					undefinedGlobal = 'Error', -- error on globals that don't exist
					undefinedField = 'Error',  -- warn on fields not listed in @field
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
local ensure_installed = vim.tbl_keys(servers or {})


-- LSP servers and clients are able to communicate to each other what features they support.
--  By default, Neovim doesn't support everything that is in the LSP specification.
--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Install on startup if there are any LSPs missing
vim.api.nvim_create_user_command('MasonInstallEnsured', function()
	vim.list_extend(ensure_installed, {
		'stylua',                          -- Used to format Lua code
		'lua_ls',                          -- For Lua
		'intelephense',                    -- For PHP (maybe not best, but at least it doesn't requires payment
		'svelte-language-server',          -- For Svelte
		'tailwindcss-language-server',     -- For Tailwind
		'vtsls',                           -- For TypeScript (better than ts-server)
		'write-good',                      -- Don't know what it is really. Testing it...
		'sqlls',                           -- For SQL
		'rust_analyzer',                   -- For Rust
		'prettier',                        -- For formatting JS, TS, HTML, CSS, Svelte, etc.
		'emmet_ls',                        -- For HTML, CSS, JS, TS, Svelte, etc.
		'json-lsp',                        -- For JSON
		'dockerls',                        -- For Docker
		'docker_compose_language_service', -- For Docker Compose
		'justls',                          -- For Justfile
		'yaml-language-server',            -- For YAML
		'markdownlint',                    -- For Markdown
	})
	vim.cmd('MasonInstall ' .. table.concat(ensure_installed, ' '))
end, {})

-- Ensure the servers and tools above are installed
--  To check the current status of installed tools and/or manually install
--  other tools, you can run
--    :Mason
--
--  You can press `g?` for help in this menu.
require('mason').setup({
	ensure_installed = ensure_installed,
})

require('mason-tool-installer').setup({
	ensure_installed = ensure_installed,
})

require('mason-lspconfig').setup({
	handlers = {
		function(server_name)
			local server = servers[server_name] or {}
			-- This handles overriding only values explicitly passed
			-- by the server configuration above. Useful when disabling
			-- certain features of an LSP (for example, turning off formatting for ts_ls)
			server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
			require('lspconfig')[server_name].setup(server)
		end,
	},
})
