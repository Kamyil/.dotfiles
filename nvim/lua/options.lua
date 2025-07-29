-- Contains all vim options settings
--
--

-- Needed for very own specific settings that are not related to vim globals
local M = {}

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' ' -- Sets the global leader key to <space>
vim.g.maplocalleader = ' ' -- Sets the local leader key to <space>

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true -- Enables Nerd Font support for icons

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`
--
-- 4 space indents by default (overriden per project later)
vim.opt.tabstop = 4 -- Number of spaces that a <Tab> in the file counts for
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> counts for while performing editing operations
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true -- Use spaces instead of tabs
-- I don't like line wrapping
vim.opt.wrap = false -- Disable line wrapping

-- Set encoding to UTF-8
vim.o.encoding = 'utf-8' -- Sets the internal encoding
vim.o.fileencoding = 'utf-8' -- Sets the encoding for the current file
vim.o.fileencodings = 'utf-8' -- Sets the list of encodings to try when reading a file

-- set global statusline across all splits
vim.opt.laststatus = 0 -- 0: Never, 1: Only if there are at least two windows, 2: Always, 3: Global statusline

-- Don't do swaps of a file, but rather save the state for undotree in order to be able to access file state from ages ago
vim.opt.swapfile = false -- Disable swap file creation
vim.opt.backup = false -- Disable backup file creation
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir' -- Directory to store undo history
vim.opt.undofile = true -- Enable persistent undo
vim.opt.updatetime = 100 -- Time in milliseconds to wait before triggering the swap/undo file write (default 4000)

vim.opt.incsearch = true -- Show search matches as you type

vim.opt.termguicolors = true -- Enable 24-bit RGB color in the TUI

-- Make line numbers default
vim.opt.number = true -- Show absolute line numbers
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true -- Show relative line numbers

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a' -- Enable mouse support in all modes

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false -- Hide the mode (e.g., -- INSERT --) since statusline shows it

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus' -- Use system clipboard for all operations
end)

-- Enable break indent
vim.opt.breakindent = true -- Enable break indent (preserves indentation in wrapped lines)

-- Save undo history
vim.opt.undofile = true -- Enable persistent undo (again, for redundancy)

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true -- Ignore case in search patterns
vim.opt.smartcase = true -- Override ignorecase if search pattern contains uppercase

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes' -- Always show the sign column (for git/lsp/etc. signs)

-- Decrease update time
vim.opt.updatetime = 50 -- Faster completion and CursorHold events

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 200 -- Time in ms to wait for a mapped sequence to complete

-- Configure how new splits should be opened
vim.opt.splitright = true -- Vertical splits open to the right
vim.opt.splitbelow = true -- Horizontal splits open below

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = false -- Do not show whitespace characters by default
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- Characters to use for displaying whitespace

vim.opt.fillchars = { eob = ' ' } -- Change the character at the end of buffer (empty lines)

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split' -- Show the effects of :substitute incrementally in a split window

-- Show which line your cursor is on
vim.opt.cursorline = true -- Highlight the current line

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 8 -- Keep 8 lines visible above/below the cursor
vim.opt.ruler = false -- Don't show the ruler (line/column info)
vim.opt.sidescrolloff = 8 -- Keep 8 columns visible to the left/right of the cursor

-- Enable settings per project
vim.g.editorconfig = true -- Enable EditorConfig support

-- Enable icons (`nvim-tree/nvim-web-devicons` plugin in this case)
vim.g.icons_enabled = true -- Enable icons in plugins

-- Disable default LSP inline diagnostic, in favor of `lsp-lines.nvim`
vim.diagnostic.config({
  virtual_text = false, -- Ensure virtual text is disabled since lsp_lines handles it
  virtual_lines = { only_current_line = true }, -- Show virtual lines for all lines
  signs = true, -- Show signs in the sign column
  underline = true, -- Underline diagnostics
  update_in_insert = false, -- Don't update diagnostics in insert mode
  severity_sort = true, -- Sort diagnostics by severity
})

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
vim.opt.spell = false -- Disable spell checking by default
vim.opt.spelllang = { 'en_us', 'pl_PL' } -- Set spell check languages

vim.opt.winborder = 'single' -- Set window border style to single line
vim.g.autoformat = false -- Disable autoformatting by default

--
return M
