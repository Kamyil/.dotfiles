-- REQUIRES NVIM v0.10.0+ to work with lazy.nvim package manager

-- MHFU-style border characters (from colors/mhfu-pokke.lua theme)
-- Available styles: rounded, dashed, braille, blocks, stippled, shaded, diagonal, mhfu
local border_styles = {
	rounded = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
	dashed = { '┌', '╌', '┐', '╎', '┘', '╌', '└', '╎' },
	braille = { '⣏', '⣉', '⣹', '⣿', '⣹', '⣉', '⣏', '⣿' },
	blocks = { '▛', '▀', '▜', '▐', '▟', '▄', '▙', '▌' },
	stippled = { '░', '░', '░', '░', '░', '░', '░', '░' },
	shaded = { '▒', '▒', '▒', '▒', '▒', '▒', '▒', '▒' },
	diagonal = { '╱', '─', '╲', '│', '╱', '─', '╲', '│' },
	-- MHFU Diamond style - matches Kitty tab bar aesthetic
	-- ◆━━━━━━━━━━◆
	-- ┃ content  ┃
	-- ◆━━━━━━━━━━◆
	mhfu = { '◆', '━', '◆', '┃', '◆', '━', '◆', '┃' },
	-- MHFU with thinner borders (alternative)
	mhfu_light = { '◇', '─', '◇', '│', '◇', '─', '◇', '│' },
}
-- Choose your border style here:
local borders = border_styles.mhfu

-- OPTIONS -- (boring but important stuff)
vim.o.number = true
vim.o.relativenumber = true
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
vim.o.guifont = 'Berkeley Mono:h12'
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
vim.opt.autoread = true -- Required for opencode.nvim auto_reload
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
	{
		'Wansmer/symbol-usage.nvim',
		event = 'LspAttach',
		config = function()
			require('symbol-usage').setup()
		end,
	},

	'folke/snacks.nvim',  -- Collection of quality of life plugins that are useful for most people

	'utilyre/barbecue.nvim', -- Showing breadcrumbs at the top of the screen

	-- Misc --
	'nvim-tree/nvim-web-devicons', -- Icons
	'chentoast/marks.nvim',     -- Show marks next to line number if there is one (and make them last when quitting Neovim)
	'folke/which-key.nvim',     -- Shows available shortcuts when hitting <leader> or some motion
	'windwp/nvim-autopairs',    -- Autopair brackets, strings etc.
	{
		'Saghen/blink.cmp',
		version = '1.*',
	}, -- Better Autocompletion

	-- AI
	'supermaven-inc/supermaven-nvim', -- Better AI suggestions
	'zbirenbaum/copilot.lua',      -- GitHub Copilot (bundles copilot-language-server)

	-- Indentation / tabstop
	'lukas-reineke/indent-blankline.nvim', -- Add indentation guides even on blank lines
	'farmergreg/vim-lastplace',         -- Automatically jump to the last cursor position
	'tpope/vim-sleuth',                 -- Detect tabstop and shiftwidth automatically

	-- Themes / Colorschemes
	'sho-87/kanagawa-paper.nvim',      -- Colorscheme / theme
	'catppuccin/nvim',                 -- Alternative colorscheme
	'vague2k/vague.nvim',              -- Alternative colorscheme
	'ramojus/mellifluous.nvim',        -- Alternative colorscheme
	"folke/tokyonight.nvim",            -- Alternative colorscheme

	'nvim-lualine/lualine.nvim',       -- Statusline

	{
		'stevearc/oil.nvim',
		-- opts configured after colorscheme loads (see below)
		dependencies = { 'nvim-tree/nvim-web-devicons' },
	}, -- File explorer in popup
	'ibhagwan/fzf-lua',                -- Other very fast picker for other things than files
	{
		'dmtrKovalenko/fff.nvim',          -- Fast fuzzy file finder with pre-built Rust binary
		build = function()
			require('fff.download').download_or_build_binary()
		end,
		lazy = false,
	},
	'echasnovski/mini.surround',       -- Allows to surround selected text with brackets, quotes, tags etc.
	{
		'nvim-treesitter/nvim-treesitter', -- Tresitter (for coloring syntax and doing AST-based operations)
		lazy = false,
		config = function()
			local ok, treesitter_configs = pcall(require, 'nvim-treesitter.configs')
			if ok then
				treesitter_configs.setup({
					ensure_installed = { 'svelte', 'typescript', 'javascript', 'php' },
					highlight = { enable = true },
				})
			end
		end,
	},
	'alexghergh/nvim-tmux-navigation', -- Better navigation with TMUX (can move between nvim and tmux splits with same motions)
	'folke/lazydev.nvim',              -- Better neovim config editing, without any non-valid warnings
	'folke/todo-comments.nvim',        -- Highlight comments like TODO, FIXME, BUG, INFO etc.
	'mluders/comfy-line-numbers.nvim', -- More comfortable vertical motions (without needing to reach so far away from current buttons)
	'brenoprata10/nvim-highlight-colors', -- Highlight color codes

	-- Git
	{ 'akinsho/git-conflict.nvim', version = '*', config = true }, -- Coloring Git Conflict inline
	'FabijanZulj/blame.nvim', -- Show git blame info in the gutter

	-- Harpoon
	{
		'ThePrimeagen/harpoon',
		branch = 'harpoon2',    -- For better switching between files. Add files to the jumplist and switch between them with Alt+1,2,3,4,5. Also edit jumplist like a vim buffer
	},

	-- Markdown notetaking
	'epwalsh/obsidian.nvim',
	'bullets-vim/bullets.vim',
	'MeanderingProgrammer/render-markdown.nvim',
	'bngarren/checkmate.nvim',
	{
		'Kamyil/markdown-agenda.nvim',
		lazy = false,
		opts = {
			directory = '~/second-brain',
			keymaps = {
				open = false,
			},
		},
	},

	'ThePrimeagen/refactoring.nvim', -- Refactoring

	{ 'mbbill/undotree', cmd = 'UndotreeToggle' }, -- Undo history visualizer

	'NickvanDyke/opencode.nvim',  -- Opencode AI assistant integration

	{
		'mshiyaf/todoist.nvim',
		dependencies = { 'ibhagwan/fzf-lua' },
		lazy = false,
	},

	{
		'TheNoeTrevino/haunt.nvim',
		opts = {
			sign = '󱙝',
			sign_hl = 'DiagnosticInfo',
			virt_text_hl = 'HauntAnnotation',
			annotation_prefix = ' 󰆉 ',
			line_hl = nil,
			virt_text_pos = 'eol',
			data_dir = nil,
			picker_keys = {
				delete = { key = 'd', mode = { 'n' } },
				edit_annotation = { key = 'a', mode = { 'n' } },
			},
		},
		init = function()
			local haunt = require('haunt.api')
			local haunt_picker = require('haunt.picker')
			local map = vim.keymap.set
			local prefix = '<leader>h'

			-- annotations
			map('n', prefix .. 'a', function()
				haunt.annotate()
			end, { desc = 'Annotate' })

			map('n', prefix .. 't', function()
				haunt.toggle_annotation()
			end, { desc = 'Toggle annotation' })

			map('n', prefix .. 'T', function()
				haunt.toggle_all_lines()
			end, { desc = 'Toggle all annotations' })

			map('n', prefix .. 'd', function()
				haunt.delete()
			end, { desc = 'Delete bookmark' })

			map('n', prefix .. 'C', function()
				haunt.clear_all()
			end, { desc = 'Delete all bookmarks' })

			-- move
			map('n', prefix .. 'p', function()
				haunt.prev()
			end, { desc = 'Previous bookmark' })

			map('n', prefix .. 'n', function()
				haunt.next()
			end, { desc = 'Next bookmark' })

			-- picker
			map('n', prefix .. 'l', function()
				haunt_picker.show()
			end, { desc = 'Show Picker' })
		end,
	},
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

require('fzf-lua').setup({
	-- Load the 'ivy' profile first
	'telescope',
	winopts = {
		border = borders,
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
	grep = {
		-- One thing I missed from Telescope was the ability to live_grep and the
		-- run a filter on the filenames.
		-- Ex: Find all occurrences of "enable" but only in the "plugins" directory.
		-- With this change, I can sort of get the same behaviour in live_grep.
		-- ex: > enable --*/plugins/*
		-- I still find this a bit cumbersome. There's probably a better way of doing this.
		rg_glob = true,      -- enable glob parsing
		glob_flag = '--iglob', -- case insensitive globs
		glob_separator = '%s%-%-', -- query separator pattern (lua): ' --'
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

keymap('n', '<leader>ff', function()
	require('fff').find_files()
end, { desc = '[F]ind [F]iles' })
-- keymap('n', '<leader>fF', fff.find_files, { desc = '[F]ind (ALL) [F]iles' })
keymap('n', '<leader>fw', fzf_lua.live_grep, { desc = '[F]ind [W]ords' })
keymap('n', '<leader>fk', fzf_lua.keymaps, { desc = '[F]ind [K]eymaps' })
-- keymap('n', '<leader>fh', ':Pick help<CR>')
keymap('n', '<leader>e', function()
	require('oil').open_float()
end, { desc = 'File [E]xplorer (popup)' })
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
		border = borders,
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
			input = { border = borders },
			list = { border = borders },
			preview = { border = borders },
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

local nvim_tmux_nav = require('nvim-tmux-navigation')
nvim_tmux_nav.setup({
	disable_when_zoomed = false,
	keybindings = {
		left = '<C-h>',
		down = '<C-j>',
		up = '<C-k>',
		right = '<C-l>',
		last_active = '<C-\\>',
		next = '<C-Space>',
	},
})

-- keymap('n', '<leader>o', ':update<CR> :source<CR>') -- source file inline (most useful for editing neovim config file
keymap('n', '<leader>w', ':write<CR>')
keymap('n', '<leader>u', '<cmd>UndotreeToggle<CR>', { desc = 'Toggle [U]ndotree' })
keymap('n', '<leader>q', ':qa<CR>', { desc = 'Quit Neovim completely' })

require('refactoring').setup({
	show_success_message = false, -- shows a message with information about the refactor on success
})
keymap({ 'n', 'x' }, '<leader>rr', function()
	require('refactoring').select_refactor()
end)

-- Opencode keymaps
keymap({ 'n', 'x' }, '<leader>aa', function()
	require('opencode').ask('@this: ', { submit = true })
end, { desc = '[A]I [A]sk about this' })
keymap({ 'n', 'x' }, '<leader>as', function()
	require('opencode').select()
end, { desc = '[A]I [S]elect prompt' })
keymap({ 'n', 'x' }, '<leader>a+', function()
	require('opencode').prompt('@this')
end, { desc = '[A]I Add this' })
keymap('n', '<leader>at', function()
	require('opencode').toggle()
end, { desc = '[A]I [T]oggle embedded' })
keymap('n', '<leader>ac', function()
	require('opencode').command()
end, { desc = '[A]I Select [C]ommand' })
keymap('n', '<leader>an', function()
	require('opencode').command('session_new')
end, { desc = '[A]I [N]ew session' })
keymap('n', '<leader>ai', function()
	require('opencode').command('session_interrupt')
end, { desc = '[A]I [I]nterrupt session' })
keymap('n', '<leader>aA', function()
	require('opencode').command('agent_cycle')
end, { desc = '[A]I Cycle [A]gent' })

keymap('n', '<leader>Tt', ':TodoistTasks<CR>', { desc = '[T]odoist [T]asks' })
keymap('n', '<leader>Ty', ':TodoistToday<CR>', { desc = '[T]odoist Toda[y]' })
keymap('n', '<leader>Ta', ':TodoistAdd<CR>', { desc = '[T]odoist [A]dd task' })
keymap('n', '<leader>Tl', ':TodoistLogin<CR>', { desc = '[T]odoist [L]ogin' })
keymap('n', '<leader>TL', ':TodoistLogout<CR>', { desc = '[T]odoist [L]ogout' })

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
  require('fzf-lua').live_grep({
    cwd = second_brain,
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

local capture = require('custom.capture')
local timetracking = require('custom.timetracking')

keymap('n', '<leader>nc', capture.capture, { desc = '[N]ote [C]apture to weekly' })
keymap('n', '<leader>na', '<cmd>MarkdownAgenda<cr>', { desc = '[N]ote [A]genda view' })

keymap('n', '<leader>nts', timetracking.start, { desc = '[N]ote [T]ime [S]tart' })
keymap('n', '<leader>nte', timetracking.stop, { desc = '[N]ote [T]ime [E]nd' })

-- Harpoon setup (quick file switching between files that I currently work on)
local harpoon = require('harpoon')
-- local harpoon_mark = require('harpoon.mark');

harpoon:setup()

keymap('n', '<A-a>', function()
	harpoon:list():add()
end) -- add file to harpoon jumplist
keymap('n', '<A-e>', function()
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

local transparent_background = true
require('catppuccin').setup({
	transparent_background = false,
	term_colors = true,

	auto_integrations = true,
	-- '#1E1E28'
	color_overrides = {},
	highlight_overrides = {
		all = function(cp)
			return {
				-- For base configs
				NormalFloat = { fg = cp.text, bg = transparent_background and cp.none or cp.mantle },
				FloatBorder = {
					fg = transparent_background and cp.blue or cp.mantle,
					bg = transparent_background and cp.none or cp.mantle,
				},
				CursorLineNr = { fg = cp.green },

				-- For native lsp configs
				DiagnosticVirtualTextError = { bg = cp.none },
				DiagnosticVirtualTextWarn = { bg = cp.none },
				DiagnosticVirtualTextInfo = { bg = cp.none },
				DiagnosticVirtualTextHint = { bg = cp.none },
				LspInfoBorder = { link = 'FloatBorder' },

				-- For mason.nvim
				MasonNormal = { link = 'NormalFloat' },

				-- For indent-blankline
				IblIndent = { fg = cp.surface0 },
				IblScope = { fg = cp.surface2, style = { 'bold' } },

				-- For nvim-cmp and wilder.nvim
				Pmenu = { fg = cp.overlay2, bg = transparent_background and cp.none or cp.base },
				PmenuBorder = { fg = cp.surface1, bg = transparent_background and cp.none or cp.base },
				PmenuSel = { bg = cp.green, fg = cp.base },
				CmpItemAbbr = { fg = cp.overlay2 },
				CmpItemAbbrMatch = { fg = cp.blue, style = { 'bold' } },
				CmpDoc = { link = 'NormalFloat' },
				CmpDocBorder = {
					fg = transparent_background and cp.surface1 or cp.mantle,
					bg = transparent_background and cp.none or cp.mantle,
				},

				-- For fidget
				FidgetTask = { bg = cp.none, fg = cp.surface2 },
				FidgetTitle = { fg = cp.blue, style = { 'bold' } },

				-- For nvim-notify
				NotifyBackground = { bg = cp.base },

				-- For nvim-tree
				NvimTreeRootFolder = { fg = cp.pink },
				NvimTreeIndentMarker = { fg = cp.surface2 },

				-- For trouble.nvim
				TroubleNormal = { bg = transparent_background and cp.none or cp.base },
				TroubleNormalNC = { bg = transparent_background and cp.none or cp.base },

				-- For telescope.nvim
				TelescopeMatching = { fg = cp.lavender },
				TelescopeResultsDiffAdd = { fg = cp.green },
				TelescopeResultsDiffChange = { fg = cp.yellow },
				TelescopeResultsDiffDelete = { fg = cp.red },

				-- For glance.nvim
				GlanceWinBarFilename = { fg = cp.subtext1, style = { 'bold' } },
				GlanceWinBarFilepath = { fg = cp.subtext0, style = { 'italic' } },
				GlanceWinBarTitle = { fg = cp.teal, style = { 'bold' } },
				GlanceListCount = { fg = cp.lavender },
				GlanceListFilepath = { link = 'Comment' },
				GlanceListFilename = { fg = cp.blue },
				GlanceListMatch = { fg = cp.lavender, style = { 'bold' } },
				GlanceFoldIcon = { fg = cp.green },

				-- For nvim-treehopper
				TSNodeKey = {
					fg = cp.peach,
					bg = transparent_background and cp.none or cp.base,
					style = { 'bold', 'underline' },
				},

				-- For treesitter
				-- ["@keyword.return"] = { fg = cp.pink, style = clear },
				-- ["@error.c"] = { fg = cp.none, style = clear },
				-- ["@error.cpp"] = { fg = cp.none, style = clear },
			}
		end,
	},
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
	terminal_colors = false,
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
		ink = { brightness = -1, saturation = -1 },
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
		implementation = 'prefer_rust',
		prebuilt_binaries = {
			force_version = '1.*.*',
		},
	},
	completion = {
		menu = {
			border = borders,
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
				border = borders,
			},
		},
		list = {
			selection = { preselect = false, auto_insert = false },
		},
	},
	signature = {
		enabled = true,
		window = {
			border = borders,
		},
	},
	sources = {
		default = { 'lsp', 'path', 'snippets', 'buffer' },
		per_filetype = {
			codecompanion = { 'codecompanion' },
		},
	},
})

require('vague').setup({
	-- optional configuration here
})


-- Zenbones setup
-- require("zenbones").setup()

-- Melange setup (no specific setup required, it's ready to use)

-- Everforest setup
-- vim.g.everforest_background = 'medium' -- 'hard', 'medium', 'soft'
-- vim.g.everforest_better_performance = 1
-- vim.g.everforest_transparent_background = 1
--
-- -- Edge setup
-- vim.g.edge_style = 'default' -- 'default', 'aura', 'neon'
-- vim.g.edge_better_performance = 1
-- vim.g.edge_transparent_background = 1
--
-- -- Nord setup
-- require('nord').setup({
-- 	transparent = true,
-- 	terminal_colors = true,
-- 	diff = { mode = 'bg' },
-- 	borders = true,
-- 	errors = { mode = 'bg' },
-- })
--
-- Set colorscheme
vim.cmd('colorscheme kanagawa-paper-ink')
-- vim.cmd('colorscheme catppuccin-mocha')
-- vim.cmd('colorscheme tokyonight-night')
-- vim.cmd('colorscheme mhfu-pokke')
vim.cmd(':hi statusline guibg=NONE')

-- MHFU border highlight - warm wood tones matching Kitty tab bar
vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#b89060', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#1a1816' })

-- Set global window border (after colorscheme loads)
vim.opt.winborder = 'rounded'

-- Configure oil.nvim float border (after theme loads)
require('oil').setup({
	default_file_explorer = false,
	view_options = {
		show_hidden = true,
	},
	float = {
		padding = 2,
		max_width = 120,
		max_height = 30,
		border = borders,
	},
	keymaps = {
		['q'] = 'actions.close',
	},
})

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
		border = borders,
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

	{ '<leader>f', group = 'Find', icon = '󰍉' },
	{ '<leader>ff', icon = '󰈞' },
	{ '<leader>fw', icon = '󰈬' },
	{ '<leader>fk', icon = '󰌌' },

	{ '<leader>g', group = 'Git', icon = '󰊢' },
	{ '<leader>gg', icon = '󰊢' },
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

	{ '<leader>T', group = 'Todoist', icon = '󰄲' },
	{ '<leader>Tt', icon = '󰄲' },
	{ '<leader>Ty', icon = '󰃭' },
	{ '<leader>Ta', icon = '󰐕' },
	{ '<leader>Tl', icon = '󰍂' },
	{ '<leader>TL', icon = '󰍃' },

	{ '<leader>e', icon = '󰉋' },
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

require('render-markdown').setup({})
require('blame').setup({})

require('todoist').setup({
	keymaps = { enable = false },
})

require('copilot').setup({
	panel = { enabled = false },
	suggestion = { enabled = true },
	copilot_node_command = '/Users/kamil/.local/share/fnm/node-versions/v22.17.1/installation/bin/node',
})

keymap({ 'i' }, '<M-j>', 'copilot#accept("<CR>")', { expr = true, silent = true, desc = 'Accept Copilot suggestion' })

require('barbecue').setup({
	attach_navic = false, -- disable navic integration since we only want file path
	show_navic = false, -- don't show LSP context symbols
	show_dirname = true, -- show directory path
	show_basename = true, -- show file name
	context_follow_icon_color = false,
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
local mhfu_theme = {
	normal = {
		a = { fg = '#1a1816', bg = '#9a7050', gui = 'bold' },
		b = { fg = '#d4c8b0', bg = '#2a2520' },
		c = { fg = '#9a8a70', bg = '#1a1816' },
	},
	insert = {
		a = { fg = '#1a1816', bg = '#7a9a6a', gui = 'bold' },
	},
	visual = {
		a = { fg = '#1a1816', bg = '#c4a860', gui = 'bold' },
	},
	replace = {
		a = { fg = '#1a1816', bg = '#a85a5a', gui = 'bold' },
	},
	command = {
		a = { fg = '#1a1816', bg = '#b89060', gui = 'bold' },
	},
	inactive = {
		a = { fg = '#6a5040', bg = '#1a1816' },
		b = { fg = '#6a5040', bg = '#1a1816' },
		c = { fg = '#6a5040', bg = '#1a1816' },
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
		theme = mhfu_theme,
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
			{ 'mode', fmt = function(str) return str:sub(1, 1) end },
		},
		lualine_b = {
			{ 'branch', icon = '' },
			{ harpoon_display, color = {} },
			{ timetracking.statusline, color = { fg = '#f7768e' } },
		},
		lualine_b = {
			{ 'branch', icon = '' },
			{ harpoon_display, color = {} },
		},
		lualine_c = {
			{ 'filename', path = 1, symbols = { modified = '', readonly = '', unnamed = '[No Name]' } },
			{ diagnostics_with_icons, color = {} },
			{ git_diff_display, color = {} },
		},
		lualine_x = {
			{ filetype_with_icon, colored = false },
			{ 'encoding', fmt = function(str) return str ~= 'utf-8' and str or '' end },
			{ 'fileformat', symbols = { unix = '', dos = '', mac = '' } },
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
