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

require('render-markdown').setup({
    heading = {
        -- Enable heading icon & background rendering
        enabled = true,
        -- Replace '#' markers with icons per heading level
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        -- Overlay icons over the '#' markers (concealed)
        position = 'overlay',
        -- Show heading icons in the sign column
        sign = true,
        signs = { '󰫎 ' },
        -- Background width: 'full' spans the window, 'block' wraps text
        width = { 'full', 'full', 'block', 'block', 'block', 'block' },
        -- Add border above/below h1 and h2
        border = { true, true, false, false, false, false },
        border_virtual = true,
        above = '▄',
        below = '▀',
        -- Margin/padding for visual breathing room
        left_margin = 0,
        left_pad = 1,
        right_pad = 1,
        -- Highlight group names per heading level
        backgrounds = {
            'RenderMarkdownH1Bg',
            'RenderMarkdownH2Bg',
            'RenderMarkdownH3Bg',
            'RenderMarkdownH4Bg',
            'RenderMarkdownH5Bg',
            'RenderMarkdownH6Bg',
        },
        foregrounds = {
            'RenderMarkdownH1',
            'RenderMarkdownH2',
            'RenderMarkdownH3',
            'RenderMarkdownH4',
            'RenderMarkdownH5',
            'RenderMarkdownH6',
        },
    },
    -- Enable anti-conceal: show concealed '#' markers on cursor line
    anti_conceal = {
        enabled = true,
    },
})
require('blame').setup({})

require('barbecue').setup({
	attach_navic = false, -- disable navic integration since we only want file path
	show_navic = true, -- don't show LSP context symbols
	show_dirname = true, -- show directory path
	show_basename = true, -- show file name
	context_follow_icon_color = true,
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
