local M = {}
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

M.ts_parser_install_dir = ts_parser_install_dir
return M
