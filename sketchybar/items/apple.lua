local icons = require("icons")
local settings = require("settings")
local sbar = require("sketchybar")

sbar.add("item", {
	default = true,
	icon = {
		padding_left = settings.padding.icon_item.icon.padding_left,
		padding_right = settings.padding.icon_item.icon.padding_right,
		string = icons.apple,
	},
	label = { drawing = false },
	click_script = "$CONFIG_DIR/plugins/apple.sh",
	subscribe = "logo mouse.clicked window_focus front_app_switched space_change title_change",
})