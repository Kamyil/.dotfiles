-- Clock matching waybar's clock format
-- waybar: "{:%A %H:%M}" - Full weekday + 24h time
local sbar = require("sketchybar")
local fonts = require("fonts")
local settings = require("settings")

local clock = sbar.add("item", "clock", {
	position = "center",
	icon = {
		font = {
			family = fonts.font.text,
			style = fonts.font.style_map["Regular"],
			size = fonts.font.size,
		},
		padding_left = 0,
		padding_right = 0,
	},
	label = {
		font = {
			family = fonts.font.text,
			style = fonts.font.style_map["Regular"],
			size = fonts.font.size,
		},
		padding_left = 0,
		padding_right = 0,
	},
	update_freq = 30,
})

clock:subscribe({ "forced", "routine", "system_woke" }, function()
	-- Format matching waybar: Full weekday + 24h time (e.g., "Friday 14:30")
	local weekday = os.date("%A")
	local time = os.date("%H:%M")
	clock:set({ 
		label = weekday .. " " .. time,
	})
end)
