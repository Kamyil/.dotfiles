-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
local helpers = require('helpers')

-- helper for consistent key mapping
local map = function(keys, func, desc, mode)
  mode = mode or 'n'
  if type(mode) == 'table' then
    for _, m in ipairs(mode) do
      vim.keymap.set(m, keys, func, { desc = desc })
    end
  else
    vim.keymap.set(mode, keys, func, { desc = desc })
  end
end

map('<leader>cp', '<cmd>Legendary<CR>', '[C]ommand [P]alette')
map('<leader>qq', '<cmd>q!<CR><cmd>Neotree close<CR>', 'Quickly quit (aborting everything in the same time)')

map('<leader>/', '<cmd>gcc<CR>', 'Comment the line or selection')

-- Open neo-tree at current file or working directory
-- INFO: Replace with yazi plugin
map('<leader>e', function()
  -- Helper function to calculate centered neo-tree width
  local reveal_file = vim.fn.expand('%:p')

  if reveal_file == '' then
    reveal_file = vim.fn.getcwd()
  else
    local f = io.open(reveal_file, 'r')
    if f then
      f:close()
    else
      reveal_file = vim.fn.getcwd()
    end
  end
  vim.cmd('Neotree reveal_file=%')
end, 'Open neo-tree at current file')

map('<leader>E', '<cmd>Yazi<cr>', 'Open Yazi in current directory')

map('<leader>w', '<cmd>w<CR>', 'Save file')

-- INFO: Solve issues reported by LSP with help of folke/trouble.nvim plugin
map('<leader>dd', '<cmd>Trouble diagnostics toggle<cr>', 'Toggle LSP diagnostics (via trouble)')
map('<leader>dq', '<cmd>Trouble qflist toggle<cr>', 'Move diagnostics to quickfix list')

-- Attempt to load Telescope
helpers.on_lazy_plugin_loaded('telescope.builtin', function(telescope_builtin)
  -- now we can do the telescope mappings
  -- Telescope mappings
  map('<leader>ff', telescope_builtin.find_files, '[F]ind [F]iles')
  -- Find files, including gitignored and hidden ones
  map('<leader>fF', function()
    telescope_builtin.find_files({
      no_ignore = true,
      hidden = true,
    })
  end, '[F]ind (ALL) [F]iles (including hidden & gitignored ones)')

  -- Normal search through git included files
  map('<leader>fw', telescope_builtin.live_grep, '[F]ind [W]ord (by using grep)')
  -- Live grep, including gitignored and hidden ones
  map('<leader>fW', function()
    telescope_builtin.live_grep({
      additional_args = function()
        return { '--no-ignore' }
      end,
    })
  end, '[F]ind [W]ords (including hidden & gitignored ones)')

  -- Searches for the word (or string) under your cursor or the one you provide when invoking the command.
  -- It's like running grep for a specific string or word without further input, typically on the current word or a provided string.
  -- Example use case: You place your cursor on a word (e.g., functionName) and then press <leader>fw. It will immediately search all occurrences of that word across your project without any further input.
  map('<leader>fcw', telescope_builtin.grep_string, '[F]ind [C]urrent [W]ord')

  map('<leader>fh', telescope_builtin.help_tags, '[F]ind [H]elp')
  map('<leader>fk', telescope_builtin.keymaps, '[F]ind [K]eymaps')
  map('<leader>fst', telescope_builtin.builtin, '[F]ind [S]elect Telescope')
  map('<leader>fcs', telescope_builtin.colorscheme, '[F]ind [C]olor[S]chemes')
  map('<leader>fd', telescope_builtin.diagnostics, '[F]ind [D]iagnostics')
  map('<leader>fr', telescope_builtin.resume, '[F]ind [R]esume')
  map('<leader>fl', telescope_builtin.oldfiles, '[F]ind [L]ast files')
  map('<leader><leader>', telescope_builtin.buffers, '[ ] Find existing buffers')

  map('gd', require('telescope.builtin').lsp_definitions, '[G]o to [D]efinition')

  -- Find references for the word under your cursor.
  map('gr', require('telescope.builtin').lsp_references, '[G]o to [R]eferences')

  -- Jump to the implementation of the word under your cursor.
  --  Useful when your language has ways of declaring types without an actual implementation.
  map('gI', require('telescope.builtin').lsp_implementations, '[G]o to [I]mplementation')

  -- WARN: This is not Goto Definition, this is Goto Declaration.
  --  For example, in C this would take you to the header.
  map('gD', vim.lsp.buf.declaration, '[G]o to [D]eclaration')

  -- LSP related actions (but still related to telescope)

  -- Jump to the type of the word under your cursor.
  --  Useful when you're not sure what type a variable is and you want to see
  --  the definition of its *type*, not where it was *defined*.
  map('<leader>ltd', require('telescope.builtin').lsp_type_definitions, '[L]SP [T]ype [D]efinition')

  -- Fuzzy find all the symbols in your current document.
  --  Symbols are things like variables, functions, types, etc.
  map('<leader>lds', require('telescope.builtin').lsp_document_symbols, '[L]SP [D]ocument [S]ymbols')

  -- Fuzzy find all the symbols in your current workspace.
  --  Similar to document symbols, except searches over your entire project.
  map('<leader>lws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[L]SP [W]orkspace [S]ymbols')

  -- Live grep with additional options
  map('<leader>f/', function()
    telescope_builtin.live_grep({
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    })
  end, '[F]ind [/] in Open Files')

  -- Search Neovim configuration files
  map('<leader>fn', function()
    telescope_builtin.find_files({ cwd = vim.fn.stdpath('config') })
  end, '[F]ind [N]eovim files')
end)

-- Rename the variable under your cursor.
--  Most Language Servers support renaming across files, etc.
map('<leader>lr', vim.lsp.buf.rename, '[L]SP [R]ename')

-- Execute a code action, usually your cursor needs to be on top of an error
-- or a suggestion from your LSP for this to activate.
map('<leader>la', vim.lsp.buf.code_action, '[L]SP [A]ction', { 'n', 'x' })

-- Continue with your other mappings...

-- Clear highlights on search
map('<Esc>', '<cmd>nohlsearch<CR>', 'Clear highlights on search')

-- Diagnostic quickfix
map('<leader>qf', vim.diagnostic.setloclist, 'Open diagnostic [Q]uick[F]ix list')

-- Exit terminal mode
map('<Esc><Esc>', '<C-\\><C-n>', 'Exit terminal mode', 't')

-- Disable arrow keys
-- map('<left>', '<cmd>echo "Use h to move!!"<CR>', 'Disable left arrow')
-- map('<right>', '<cmd>echo "Use l to move!!"<CR>', 'Disable right arrow')
-- map('<up>', '<cmd>echo "Use k to move!!"<CR>', 'Disable up arrow')
-- map('<down>', '<cmd>echo "Use j to move!!"<CR>', 'Disable down arrow')

-- Window navigation
helpers.on_lazy_plugin_loaded('nvim-tmux-navigation', function(nvim_tmux_nav)
  map('<C-h>', function()
    nvim_tmux_nav.NvimTmuxNavigateLeft()
  end, 'Move left to tmux pane or window')

  map('<C-j>', function()
    nvim_tmux_nav.NvimTmuxNavigateDown()
  end, 'Move down to tmux pane or window')

  map('<C-k>', function()
    nvim_tmux_nav.NvimTmuxNavigateUp()
  end, 'Move up to tmux pane or window')

  map('<C-l>', function()
    nvim_tmux_nav.NvimTmuxNavigateRight()
  end, 'Move right to tmux pane or window')

  map('<C-\\>', function()
    nvim_tmux_nav.NvimTmuxNavigateLastActive()
  end, 'Move to the last active tmux pane or window')

  --[[ map('<C-Space>', function()
    vim.notify 'Key <C-Space> pressed'
    nvim_tmux_nav.NvimTmuxNavigateNext()
  end, 'Move to the next tmux pane or window') ]]
end)

map('<C-Up>', '<cmd>resize +2<CR>', 'Resize split up')
map('<C-Down>', '<cmd>resize -2<CR>', 'Resize split down')
map('<C-Left>', '<cmd>vertical resize +2<CR>', 'Resize split left')
map('<C-Right>', '<cmd>vertical resize -2<CR>', 'Resize split right')

-- Buffer management
map('<A-,>', '<Cmd>BufferPrevious<CR>', 'Move to previous buffer')
map('<A-.>', '<Cmd>BufferNext<CR>', 'Move to next buffer')
map('<A-<>', '<Cmd>BufferMovePrevious<CR>', 'Re-order to previous buffer')
map('<A->>', '<Cmd>BufferMoveNext<CR>', 'Re-order to next buffer')

-- Buffer goto positions (allows to handly switch tabs by using 1/2/3/4/5...)
-- Kinda like Harpoon but not quite and easier
map('<A-1>', '<Cmd>BufferGoto 1<CR>', 'Go to buffer number 1')
map('<A-2>', '<Cmd>BufferGoto 2<CR>', 'Go to buffer number 2')
map('<A-3>', '<Cmd>BufferGoto 3<CR>', 'Go to buffer number 3')
map('<A-4>', '<Cmd>BufferGoto 4<CR>', 'Go to buffer number 4')
map('<A-5>', '<Cmd>BufferGoto 5<CR>', 'Go to buffer number 5')
map('<A-6>', '<Cmd>BufferGoto 6<CR>', 'Go to buffer number 6')
map('<A-7>', '<Cmd>BufferGoto 7<CR>', 'Go to buffer number 7')
map('<A-8>', '<Cmd>BufferGoto 8<CR>', 'Go to buffer number 8')
map('<A-9>', '<Cmd>BufferGoto 9<CR>', 'Go to buffer number 9')
map('<A-0>', '<Cmd>BufferLast<CR>', 'Go to last buffer')

-- Buffer actions
map('<A-p>', '<Cmd>BufferPin<CR>', 'Pin/unpin buffer')
map('<A-c>', '<Cmd>BufferClose<CR>', 'Close buffer')
map('<C-p>', '<Cmd>BufferPick<CR>', 'Magic buffer-picking mode')
map('<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', 'Order buffers by number')
map('<Space>bn', '<Cmd>BufferOrderByName<CR>', 'Order buffers by name')
map('<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', 'Order buffers by directory')
map('<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', 'Order buffers by language')
map('<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', 'Order buffers by window number')

-- Centering mappings
map('<C-d>', '<C-d>zz', 'Move down with cursor centered')
map('<C-u>', '<C-u>zz', 'Move up with cursor centered')
map('}', '}zz', 'Move paragraph down with cursor centered')
map('{', '{zz', 'Move paragraph up with cursor centered')

-- Visual mode mappings
map('J', ":m '>+1<CR>gv=gv", 'Move selected line(s) down', 'v')
map('K', ":m '<-2<CR>gv=gv", 'Move selected line(s) up', 'v')

-- Visual line mode mappings
map('<leader>r', '"_dP', 'Replace selection with register content', 'x')

-- SQL client toggle
map('<leader>sql', '<cmd>DBUIToggle<CR>', '[S][Q][L] (DB) viewer')

-- Open project scratchpad
map('<leader>ss', function()
  local project_root = helpers.get_project_root()
  local scratchpad_path = project_root .. '/.scratchpad.md'
  vim.cmd('edit ' .. scratchpad_path)
end, 'Open project scratchpad')

-- Go to the scratchpad buffer by name
vim.api.nvim_set_keymap('n', '<A-s>', ':BufferGoto ' .. vim.fn.bufnr('scratchpad.md') .. '<CR>', { noremap = true, silent = true })

helpers.on_lazy_plugin_loaded('smart-splits', function(smart_splits)
  -- Splitting windows
  map('|', '<cmd>vsplit<CR>', 'Vertical Split')
  map('_', '<cmd>split<CR>', 'Horizontal Split')

  -- Resizing windows
  map('<C-Left>', smart_splits.resize_left, 'Resize Left')
  map('<C-Right>', smart_splits.resize_right, 'Resize Right')
  map('<C-Up>', smart_splits.resize_up, 'Resize Up')
  map('<C-Down>', smart_splits.resize_down, 'Resize Down')

  -- Moving between splits
  map('<C-h>', smart_splits.move_cursor_left, 'Move to Left Split')
  map('<C-j>', smart_splits.move_cursor_down, 'Move to Bottom Split')
  map('<C-k>', smart_splits.move_cursor_up, 'Move to Top Split')
  map('<C-l>', smart_splits.move_cursor_right, 'Move to Right Split')

  -- Buffer swapping
  map('<leader>bH', smart_splits.swap_buf_left, 'Swap Buffer Left')
  map('<leader>bL', smart_splits.swap_buf_right, 'Swap Buffer Right')
  map('<leader>bK', smart_splits.swap_buf_up, 'Swap Buffer Up')
  map('<leader>bJ', smart_splits.swap_buf_down, 'Swap Buffer Down')

  -- Start persistent resize mode
  map('<leader>rs', '<cmd>lua smart_splits.start_resize_mode()<CR>', 'Start Resize Mode')
end)

-- INFO: GIT related
helpers.on_lazy_plugin_loaded('lazygit', function(lazygit)
  map('<leader>gg', '<cmd>LazyGit<CR>', 'Open Lazygit')
end)
-- -- Git Conflicts
map('<leader>gb', '<cmd>BlameToggle window<CR>', '[G]it [Blame]')
map('<leader>gcc', '<cmd>GitConflictChooseOurs<CR>', '[G]it [C]onflict Choose [C]urrent')
map('<leader>gci', '<cmd>GitConflictChooseTheirs<CR>', '[G]it [C]onflict Choose [I]ncoming')
map('<leader>gcb', '<cmd>GitConflictChooseBoth<CR>', '[G]it [Conflict] Choose [B]oth')
map('<leader>gcn', '<cmd>GitConflictChooseOurs<CR>', '[G]it [Conflict] Choose [N]one')
map('<leader>gcn', '<cmd>GitConflictChooseOurs<CR>', '[G]it [Conflict] Choose [N]one')
map('<leader>gc[', '<cmd>GitConflictChooseOurs<CR>', '[G]it [Conflict] Previous')
map('<leader>gc]', '<cmd>GitConflictChooseOurs<CR>', '[G]it [Conflict] Next')

map('<leader>yh', '<cmd>YankBank<CR>', '[Y]ank [H]istory')

-- INFO: Git Hunks
-- Actions

helpers.on_lazy_plugin_loaded('gitsigns', function(gitsigns)
  map('<leader>ghs', gitsigns.stage_hunk, '[G]it [H]unk [Stage]')
  map('<leader>ghr', gitsigns.reset_hunk, '[G]it [H]unk [R]eset')
  map('<leader>ghs', function()
    gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
  end, '[G]it [H]unk [Stage]', 'v')
  map('<leader>ghr', function()
    gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
  end, '[G]it [H]unk [R]eset lines', 'v')
  map('<leader>ghS', gitsigns.stage_buffer, '[G]it [H]unk [S]tage')
  map('<leader>ghus', gitsigns.undo_stage_hunk, '[G]it [H]unk [U]ndo [Stage]')
  map('<leader>ghR', gitsigns.reset_buffer, '[G]it [H]unk [R]eset File')
  map('<leader>ghp', gitsigns.preview_hunk, '[G]it [H]unk [P]review')
  map('<leader>ghb', function()
    gitsigns.blame_line({ full = true })
  end, '[G]it [H]unk [B]lame line')
  map('<leader>ghtb', gitsigns.toggle_current_line_blame, '[G]it [H]unk [T]oggle [B]lame')
  map('<leader>ghd', gitsigns.diffthis, '[G]it [H]unk [D]iff these lines')
  map('<leader>ghD', function()
    gitsigns.diffthis('~')
  end, '[G]it [H]unk [D]iff (whole file)')
  map('<leader>ghtd', gitsigns.toggle_deleted, '[G]it [H]unk [T]oggle [D]eleted')
end)

-- -- Harpoon
-- --
-- helpers.on_lazy_plugin_loaded('harpoon', function(harpoon)
--   harpoon:setup()
--
--   vim.keymap.set('n', '<leader>a', function()
--     harpoon:list():add()
--   end)
--   vim.keymap.set('n', '<leader>p', function()
--     harpoon.ui:toggle_quick_menu(harpoon:list())
--   end)
--
--   vim.keymap.set('n', '1', function()
--     harpoon:list():select(1)
--   end)
--   vim.keymap.set('n', '2', function()
--     harpoon:list():select(2)
--   end)
--   vim.keymap.set('n', '3', function()
--     harpoon:list():select(3)
--   end)
--   vim.keymap.set('n', '4', function()
--     harpoon:list():select(4)
--   end)
--   vim.keymap.set('n', '5', function()
--     harpoon:list():select(5)
--   end)
--   vim.keymap.set('n', '6', function()
--     harpoon:list():select(6)
--   end)
--   vim.keymap.set('n', '7', function()
--     harpoon:list():select(7)
--   end)
--   vim.keymap.set('n', '8', function()
--     harpoon:list():select(8)
--   end)
--   vim.keymap.set('n', '9', function()
--     harpoon:list():select(9)
--   end)
-- end)
--
-- better indenting
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
