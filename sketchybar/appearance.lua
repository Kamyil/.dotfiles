local settings = require("settings")
local sbar = require("sketchybar")
local fonts = require("fonts")

local M = {}

M.colors = {
	default = 0x80ffffff,
	black = 0xff181819,
	white = 0xffffffff,
	red = 0xfffc5d7c,
	red_bright = 0xe0f38ba8,
	green = 0xff9ed072,
	blue = 0xff76cce0,
	blue_bright = 0xe089b4fa,
	yellow = 0xffe7c664,
	orange = 0xfff39660,
	magenta = 0xffb39df3,
	grey = 0xff7f8490,
	transparent = 0x00000000,

	bar = {
		bg = 0x80000000,
		border = 0xff2c2e34,
	},

	popup = {
		bg = 0xFF1d1b2d,
		border = 0xff7f8490,
	},

	bg1 = 0xFF1d1b2d,
	bg2 = 0xe0313436,
	bg3 = 0x80000000,
	bg4 = 0x33000000,

	accent = 0xFFb482c2,
	accent_bright = 0x00efc2fc,
	accent_tbright = 0x33efc2fc,

	spotify_green = 0xe040a02b,

	-- Catppuccin Mocha Theme
	mocha = {
		rosewater = 0xfff5e0dc,
		flamingo = 0xfff2cdcd,
		pink = 0xfff5c2e7,
		mauve = 0xffcba6f7,
		red = 0xfff38ba8,
		maroon = 0xffeba0ac,
		peach = 0xfffab387,
		yellow = 0xfff9e2af,
		green = 0xffa6e3a1,
		teal = 0xff94e2d5,
		sky = 0xff89dceb,
		sapphire = 0xff74c7ec,
		blue = 0xff89b4fa,
		lavender = 0xffb4befe,
		text = 0xffcdd6f4,
		base = 0xff1e1e2e,
		mantle = 0xff181825,
		crust = 0xff11111b,
	},

	-- Catppuccin Macchiato Theme
	macchiato = {
		rosewater = 0xfff4dbd6,
		flamingo = 0xfff0c6c6,
		pink = 0xfff5a97f,
		mauve = 0xffc6a0f6,
		red = 0xffed8796,
		maroon = 0xffee99a0,
		peach = 0xfff5a97f,
		yellow = 0xffeed49f,
		green = 0xffa6da95,
		teal = 0xff8bd5ca,
		sky = 0xff91d7e3,
		sapphire = 0xff7dc4e4,
		blue = 0xff8aadf4,
		lavender = 0xffb7bdf8,
		text = 0xffcad3f5,
		subtext1 = 0xffb8c0e0,
		subtext0 = 0xffa5adcb,
		overlay2 = 0xff939ab7,
		overlay1 = 0xff8087a2,
		overlay0 = 0xff6e738d,
		surface2 = 0xff5b6078,
		surface1 = 0xff494d64,
		surface0 = 0xff363a4f,
		base = 0xff24273a,
		mantle = 0xff1e2030,
		crust = 0xff181926,
	},

	-- Catppuccin Latte Theme
	latte = {
		rosewater = 0xffdc8a78,
		flamingo = 0xffdd7878,
		pink = 0xffea76cb,
		mauve = 0xff8839ef,
		red = 0xffd20f39,
		maroon = 0xffe64553,
		peach = 0xfffe640b,
		yellow = 0xffdf8e1d,
		green = 0xff40a02b,
		teal = 0xff179299,
		sky = 0xff04a5e5,
		sapphire = 0xff209fb5,
		blue = 0xff1e66f5,
		lavender = 0xff7287fd,
		text = 0xff4c4f69,
		base = 0xffeff1f5,
		mantle = 0xffe6e9ef,
		crust = 0xffdce0e8,
	},

	-- Utility Function

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) * 0x1000000)
	end,
}

-- Set the active theme
M.colors.active = M.colors.macchiato

-- Holds specific styles for different components, like workspaces.
-- These are applied manually in their respective files.
M.styles = {
	-- Styles for the workspace items created in items/spaces.lua
	workspace = {
		background = {
			color = M.colors.accent_bright,
			drawing = true,
		},
		icon = {
			color = M.colors.active.white,
			highlight_color = M.colors.active.text,
			font = {
				family = fonts.font.text,
				style = fonts.font.style_map["Bold"],
				size = fonts.font.size,
			},
			padding_left = 12,
			padding_right = 2,
		},
		label = {
			color = M.colors.active.mauve,
			highlight_color = M.colors.active.peach,
			font = "sketchybar-app-font:Regular:16.0",
			padding_left = 2,
			padding_right = 12,
			y_offset = -1,
		},
	},
}

-- Sets the global default properties for all items in sketchybar.
-- Individual items can override these.
sbar.default({
	-- Default background properties for the main bar
	background = {
		border_color = M.colors.macchiato.surface0,
		border_width = 3,
		color = M.colors.bg4, -- controls colors for icons
		corner_radius = 0,
		height = 32,
		image = {
			corner_radius = 9,
			border_color = M.colors.white,
			border_width = 1,
		},
	},
	-- Default properties for all icons (e.g., apple, calendar, widgets)
	icon = {
		font = {
			family = fonts.font_icon.text,
			style = fonts.font_icon.style_map["Bold"],
			size = fonts.font_icon.size,
		},
		color = M.colors.macchiato.sapphire,
		highlight_color = M.colors.green,
		padding_left = 0,
		padding_right = 0,
	},
	-- Default properties for all text labels (e.g., volume, battery, time)
	label = {
		font = {
			family = fonts.font.text,
			style = fonts.font.style_map["Semibold"],
			size = fonts.font.size,
		},
		color = M.colors.blue,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
	},
	-- Default properties for popup menus
	popup = {
		align = "center",
		color = M.colors.white,
		background = {
			border_width = 0,
			corner_radius = 6,
			color = M.colors.macchiato.subtext1,
			shadow = { drawing = true },
		},
		blur_radius = 50,
		y_offset = 5,
	},
	padding_left = 3,
	padding_right = 3,
	scroll_texts = true,
	updates = "on",
})

return M