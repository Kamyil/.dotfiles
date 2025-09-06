# Indentation Configuration

This document explains how indentation detection and display works in this Neovim configuration.

## Overview

The indentation system combines multiple plugins and configurations to provide smart detection and accurate visual feedback for different indentation styles across projects.

## Components

### 1. Core Vim Settings

Located in `init.lua` around lines 32-37:

```lua
vim.opt.autoindent = true      -- Copy indent from current line when starting new line
vim.opt.smartindent = true     -- Smart autoindenting for new lines
vim.opt.cindent = true         -- C-style indenting
vim.opt.preserveindent = true  -- Preserve existing indentation structure
```

These settings ensure that Neovim respects and maintains existing indentation patterns when editing.

### 2. Default Indentation Settings

Default settings (lines 10-13):

```lua
vim.o.tabstop = 4           -- Tab width = 4 spaces
vim.opt.softtabstop = 4     -- Editing operations use 4 spaces
vim.opt.shiftwidth = 4      -- Auto-indent uses 4 spaces
vim.opt.expandtab = false   -- Use actual tabs, not spaces
```

These serve as fallbacks when no project-specific settings are detected.

### 3. EditorConfig Support

```lua
vim.g.editorconfig = true
```

Automatically reads `.editorconfig` files in projects to apply:
- `indent_style` (tab/space)
- `indent_size` (2, 4, 8, etc.)
- `tab_width`
- `trim_trailing_whitespace`
- `insert_final_newline`

### 4. vim-sleuth Plugin

Automatically detects indentation from existing files by analyzing:
- Whether tabs or spaces are used
- How many spaces constitute one indentation level
- Adjusts `tabstop`, `shiftwidth`, `expandtab` accordingly

### 5. Visual Indicators

#### Whitespace Display (listchars)

Located around lines 40-47:

```lua
vim.opt.listchars = { 
	tab = '→ ',      -- Show tabs as arrows with trailing space
	trail = '·',     -- Show trailing spaces as dots
	nbsp = '␣',      -- Show non-breaking spaces
	lead = '·',      -- Show leading spaces (when using spaces)
	extends = '❯',   -- Show line continuation beyond screen
	precedes = '❮',  -- Show line starts before screen
}
vim.opt.list = true -- Enable whitespace visualization
```

#### Indent Guides (indent-blankline)

Around lines 700-725:

```lua
require('ibl').setup({
	indent = {
		char = '│',        -- Vertical line for indentation levels
		tab_char = '│',    -- Same character for tab indentation
	},
	scope = {
		enabled = true,    -- Highlight current scope
		show_start = true, -- Show scope start
	},
})
```

Shows vertical lines at each indentation level, with current scope highlighting.

### 6. Enhanced Detection Autocmd

Around lines 680-698, runs on every file open:

```lua
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
	callback = function()
		vim.schedule(function()
			-- Apply different listchars based on detected indentation
			if vim.bo.expandtab then
				-- Using spaces - show leading spaces
				vim.opt_local.listchars:append({ tab = '→ ', lead = '·', trail = '·' })
			else
				-- Using tabs - don't show leading spaces
				vim.opt_local.listchars:append({ tab = '→ ', trail = '·' })
			end
			
			-- Ensure display matches detected settings
			vim.opt_local.tabstop = vim.bo.tabstop
			vim.opt_local.shiftwidth = vim.bo.shiftwidth
			vim.opt_local.softtabstop = vim.bo.softtabstop
		end)
	end,
})
```

This ensures visual display accurately reflects the detected indentation settings.

## How It Works

### Detection Priority Order

1. **EditorConfig** - Project-wide `.editorconfig` files (highest priority)
2. **vim-sleuth** - Analysis of existing file content
3. **Default settings** - Fallback configuration (lowest priority)

### Visual Feedback

| Indentation Type | What You See |
|------------------|--------------|
| **Tabs** | `→ ` for each tab character |
| **2 Spaces** | `··` (two dots) for each indent level |
| **4 Spaces** | `····` (four dots) for each indent level |
| **Mixed/Invalid** | Inconsistent dot patterns reveal problems |

### Scope Highlighting

The indent-blankline plugin highlights the current indentation scope:
- **Current scope**: Brighter vertical lines
- **Other levels**: Dimmer vertical lines
- **Function/block boundaries**: Clearly visible

## Troubleshooting

### If indentation looks wrong:

1. **Check EditorConfig**: Look for `.editorconfig` in project root
2. **Force redetection**: `:e` (reload file) or `:set filetype=<type>`
3. **Manual override**: 
   ```vim
   :set expandtab tabstop=2 shiftwidth=2 softtabstop=2
   ```
4. **Check detection**: `:verbose set expandtab? tabstop? shiftwidth?`

### Common Issues:

- **Mixed indentation**: You'll see both `→` and `·` characters
- **Wrong tab width**: Tabs appear too wide/narrow compared to git diff
- **Trailing whitespace**: Shows as `·` at line ends

## Commands

| Command | Description |
|---------|-------------|
| `:set list!` | Toggle whitespace visibility |
| `:IBLToggle` | Toggle indentation guides |
| `:EditorConfigReload` | Reload EditorConfig settings |
| `:SleuthReload` | Force vim-sleuth redetection |

## File Type Specific Behavior

Some file types have special handling:
- **Markdown**: Preserves list indentation
- **YAML**: Strict 2-space indentation
- **Makefiles**: Always use tabs
- **Python**: PEP 8 compliance (4 spaces)

The configuration automatically adapts to these conventions when detected.