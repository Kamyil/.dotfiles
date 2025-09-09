local colors = require("appearance")
local settings = require("settings")
local sbar = require("sketchybar")

-- Equivalent to the --bar domain
sbar.bar({
	color = colors.colors.bg3,
	height = settings.height,
	padding_right = 10,
	padding_left = 10,
	sticky = "on",
	topmost = "window",
	y_offset = -5,
	margin = -2,
	blur_radius = 30,
	border_color = 0x00000000,
})