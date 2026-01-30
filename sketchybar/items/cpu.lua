-- CPU widget matching waybar's cpu module
-- waybar: "format": "󰍛 {usage}%"
local sbar = require("sketchybar")
local fonts = require("fonts")
local icons = require("icons")
local settings = require("settings")

local cpu = sbar.add("item", "cpu", {
	position = "right",
	icon = {
		string = icons.cpu,
		font = {
			family = fonts.font_icon.text,
			style = fonts.font_icon.style_map["Regular"],
			size = fonts.font_icon.size,
		},
		padding_left = 0,
		padding_right = 2,
	},
	label = {
		font = {
			family = fonts.font.text,
			style = fonts.font.style_map["Regular"],
			size = fonts.font.size,
		},
		padding_left = 0,
		padding_right = settings.module_spacing,
	},
	update_freq = 5,
})

cpu:subscribe({ "routine", "system_woke" }, function()
	sbar.exec("ps -A -o %cpu | awk '{s+=$1} END {printf \"%.0f\", s}'", function(usage)
		cpu:set({
			label = usage .. "%",
		})
	end)
end)