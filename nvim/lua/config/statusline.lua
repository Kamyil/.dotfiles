
-- Lualine setup
local kanagawa_paper = {
	bg = '#1F1F28',
	bg_dark = '#16161D',
	bg_alt = '#2A2A37',
	fg = '#DCD7BA',
	fg_dim = '#C8C093',
	muted = '#aca9a4',
	red = '#c4746e',
	green = '#699469',
	yellow = '#c4b28a',
	blue = '#809ba7',
	magenta = '#a292a3',
	cyan = '#8ea49e',
}

local kanagawa_paper_theme = {
	normal = {
		a = { fg = kanagawa_paper.bg_dark, bg = kanagawa_paper.cyan, gui = 'bold' },
		b = { fg = kanagawa_paper.fg, bg = kanagawa_paper.bg_alt },
		c = { fg = kanagawa_paper.fg_dim, bg = kanagawa_paper.bg },
	},
	insert = {
		a = { fg = kanagawa_paper.bg_dark, bg = kanagawa_paper.green, gui = 'bold' },
		b = { fg = kanagawa_paper.fg, bg = kanagawa_paper.bg_alt },
		c = { fg = kanagawa_paper.fg_dim, bg = kanagawa_paper.bg },
	},
	visual = {
		a = { fg = kanagawa_paper.bg_dark, bg = kanagawa_paper.magenta, gui = 'bold' },
		b = { fg = kanagawa_paper.fg, bg = kanagawa_paper.bg_alt },
		c = { fg = kanagawa_paper.fg_dim, bg = kanagawa_paper.bg },
	},
	replace = {
		a = { fg = kanagawa_paper.bg_dark, bg = kanagawa_paper.red, gui = 'bold' },
		b = { fg = kanagawa_paper.fg, bg = kanagawa_paper.bg_alt },
		c = { fg = kanagawa_paper.fg_dim, bg = kanagawa_paper.bg },
	},
	command = {
		a = { fg = kanagawa_paper.bg_dark, bg = kanagawa_paper.yellow, gui = 'bold' },
		b = { fg = kanagawa_paper.fg, bg = kanagawa_paper.bg_alt },
		c = { fg = kanagawa_paper.fg_dim, bg = kanagawa_paper.bg },
	},
	inactive = {
		a = { fg = kanagawa_paper.muted, bg = kanagawa_paper.bg_dark },
		b = { fg = kanagawa_paper.muted, bg = kanagawa_paper.bg_dark },
		c = { fg = kanagawa_paper.muted, bg = kanagawa_paper.bg_dark },
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
		theme = kanagawa_paper_theme,
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
			{
				'mode',
				fmt = function(str)
					return str:sub(1, 1)
				end,
			},
		},
		lualine_b = {
			{ 'branch', icon = '' },
			{ harpoon_display, color = {} },
		},
		lualine_c = {
			{ 'filename',             path = 1,  symbols = { modified = '', readonly = '', unnamed = '[No Name]' } },
			{ diagnostics_with_icons, color = {} },
			{ git_diff_display,       color = {} },
		},
		lualine_x = {
			{ filetype_with_icon, colored = false },
			{
				'encoding',
				fmt = function(str)
					return str ~= 'utf-8' and str or ''
				end,
			},
			{ 'fileformat',       symbols = { unix = '', dos = '', mac = '' } },
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
