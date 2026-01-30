local colors = require("appearance")
local settings = require("settings")
local sbar = require("sketchybar")

-- Bar configuration matching waybar
-- Position: bottom, height: 26px, no blur, minimal styling
sbar.bar({
	color = colors.colors.background,
	height = settings.height,
	padding_right = settings.margin_right,
	padding_left = settings.margin_left,
	position = "bottom",
	sticky = "on",
	topmost = "off",
	y_offset = 0,
	margin = 0,
	blur_radius = 0,
	border_color = colors.colors.transparent,
	border_width = 0,
})
