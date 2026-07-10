local M = {}
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

function M.apply_terminal_theme_highlights()
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

M.apply_terminal_theme_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
	callback = M.apply_terminal_theme_highlights,
})
return M
