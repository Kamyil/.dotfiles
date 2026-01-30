-- Apple icon matching waybar's NixOS logo (custom/omarchy)
local icons = require("icons")
local settings = require("settings")
local sbar = require("sketchybar")

sbar.add("item", "apple", {
	position = "left",
	icon = {
		string = icons.apple,
		font = {
			family = "JetBrainsMono Nerd Font",
			style = "Regular",
			size = 12.0,
		},
		padding_left = 0,
		padding_right = settings.module_spacing,
	},
	label = { drawing = false },
	click_script = "open -a 'System Preferences'",
})