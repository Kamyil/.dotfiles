local sbar = require("sketchybar")
local fonts = require("fonts")

local front_app = sbar.add("item", "front_app", {
	label = {
		font = {
			family = fonts.font.text,
			style = fonts.font.style_map["Black"],
			size = 12.0,
		},
	},
	icon = {
		background = { drawing = true },
	},
	display = "active",
	script = "$CONFIG_DIR/plugins/front_app.sh",
	click_script = "open -a 'Mission Control'",
	position = "left",
})

front_app:subscribe("front_app_switched")