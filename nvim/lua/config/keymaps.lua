-- # KEYMAPS #
-- Helper function for defining key mappings / key shortcuts
-- @field mode - 'n' for normal, 'v' for visual, 'i' for insert, 'x' for all
-- @field keys - keys themselves where "C-" means Ctrl+, "A-" means "Alt+", "<leader>+" means Space+
-- @field callback - command or function to execute
-- @field options - some extra options as Lua table
-- @field options.desc - Description of a keymap, that will be displayed in which-key
local keymap = vim.keymap.set
-- Move by visual lines when text wrapping is enabled.
keymap({ 'n', 'x' }, 'j', function()
	return vim.wo.wrap and 'gj' or 'j'
end, { expr = true, desc = 'Move down by display line' })
keymap({ 'n', 'x' }, 'k', function()
	return vim.wo.wrap and 'gk' or 'k'
end, { expr = true, desc = 'Move up by display line' })

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
