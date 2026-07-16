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
require('config.plugin_setup').apply_terminal_theme_highlights()

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

-- Keep every Neovim highlight upright, including groups added by plugins.
local function disable_italics()
  for name, highlight in pairs(vim.api.nvim_get_hl(0, {})) do
    if highlight.italic then
      highlight.italic = false
      vim.api.nvim_set_hl(0, name, highlight)
    end
  end
end

disable_italics()
vim.api.nvim_create_autocmd('ColorScheme', {
	callback = disable_italics,
})

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
