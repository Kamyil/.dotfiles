local sbar = require("sketchybar")
local fonts = require("fonts")

local cal = sbar.add("item", {
	icon = {
		font = {
			family = fonts.font_heavy.text,
			style = fonts.font_heavy.style_map["Regular"],
			size = fonts.font_heavy.size,
		},
		padding_left = 8,
	},
	label = {
		align = "right",
		font = {
			family = fonts.font_heavy.text,
			style = fonts.font_heavy.style_map["Regular"],
			size = fonts.font_heavy.size,
		},
		padding_right = 10,
	},
	position = "right",
	update_freq = 30,
	padding_left = 1,
	padding_right = 1,
})

cal:subscribe({ "forced", "routine", "system_woke" }, function()
	cal:set({ icon = os.date("%a %b %d"), label = os.date("%I:%M %p") })
end)