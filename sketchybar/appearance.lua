local settings = require("settings")
local sbar = require("sketchybar")
local fonts = require("fonts")

-- Waybar-compatible color scheme from config/waybar/style.css
-- Kanagawa (previous): foreground #dcd7ba, background rgba(16, 16, 16, 0.95)
-- Catppuccin Frappé (previous): foreground #c6d0f5, background rgba(48, 52, 70, 0.95)
-- Catppuccin Mocha (previous): foreground #bac2de, background rgba(30, 30, 46, 0.95)
-- Catppuccin Mocha (previous extra-muted): foreground #aeb6d0, background rgba(37, 37, 53, 0.95)
-- Kanagawa Paper Ink (active): foreground #dcd7ba, background rgba(31, 31, 40, 0.95)
local M = {}

-- Convert hex to ARGB format for sketchybar
local function hex_to_argb(hex, alpha)
	alpha = alpha or 1.0
	local r = tonumber(hex:sub(2, 3), 16)
	local g = tonumber(hex:sub(4, 5), 16)
	local b = tonumber(hex:sub(6, 7), 16)
	local a = math.floor(alpha * 255)

	return (a * 0x1000000) + (r * 0x10000) + (g * 0x100) + b
end

M.colors = {
	-- Core colors from Kanagawa Paper Ink
	foreground = hex_to_argb("#dcd7ba"),
	background = hex_to_argb("#1f1f28", 0.95),
	background_solid = hex_to_argb("#1f1f28"),
	
	-- Accent colors
	red = hex_to_argb("#c4746e"),
	red_bright = hex_to_argb("#cc928e"),
	green = hex_to_argb("#699469"),
	blue = hex_to_argb("#698a9b"),
	yellow = hex_to_argb("#c4b28a"),
	magenta = hex_to_argb("#a292a3"),
	cyan = hex_to_argb("#8ea49e"),
	white = hex_to_argb("#dcd7ba"),
	black = hex_to_argb("#141416"),
	
	-- Transparent
	transparent = 0x00000000,
	
	-- Utility Function
	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) * 0x1000000)
	end,
}

-- Set the active theme
M.colors.active = M.colors

-- Holds specific styles for different components
M.styles = {
	-- Styles for the workspace items
	workspace = {
		background = {
			color = M.colors.transparent,
			drawing = false,
		},
		icon = {
			color = M.colors.foreground,
			highlight_color = M.colors.yellow,
			font = {
				family = fonts.font.text,
				style = fonts.font.style_map["Regular"],
				size = fonts.font.size,
			},
			padding_left = settings.workspace_spacing / 2,
			padding_right = settings.workspace_spacing / 2,
		},
		label = {
			color = M.colors.foreground,
			highlight_color = M.colors.yellow,
			font = fonts.font.text .. ":Regular:10.0",
			padding_left = 2,
			padding_right = 2,
		},
	},
}

-- Sets the global default properties for all items in sketchybar
sbar.default({
	-- Default background properties for the main bar
	background = {
		border_color = M.colors.transparent,
		border_width = 0,
		color = M.colors.transparent,
		corner_radius = 0,
		height = settings.height,
	},
	-- Default properties for all icons
	icon = {
		font = {
			family = fonts.font_icon.text,
			style = fonts.font_icon.style_map["Regular"],
			size = fonts.font_icon.size,
		},
		color = M.colors.foreground,
		padding_left = 0,
		padding_right = 0,
	},
	-- Default properties for all text labels
	label = {
		font = {
			family = fonts.font.text,
			style = fonts.font.style_map["Regular"],
			size = fonts.font.size,
		},
		color = M.colors.foreground,
		padding_left = 0,
		padding_right = 0,
	},
	-- Default properties for popup menus
	popup = {
		align = "center",
		color = M.colors.foreground,
		background = {
			border_width = 0,
			corner_radius = 0,
			color = M.colors.background,
			shadow = { drawing = false },
		},
		blur_radius = 0,
		y_offset = 0,
	},
	padding_left = 0,
	padding_right = 0,
	scroll_texts = false,
	updates = "on",
})

return M
