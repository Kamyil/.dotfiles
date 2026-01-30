-- WiFi widget matching waybar's network module
-- waybar shows icon only with tooltip for details
local sbar = require("sketchybar")
local fonts = require("fonts")
local icons = require("icons")
local settings = require("settings")

local wifi = sbar.add("item", "wifi", {
	position = "right",
	icon = {
		string = icons.wifi.connected,
		font = {
			family = fonts.font_icon.text,
			style = fonts.font_icon.style_map["Regular"],
			size = fonts.font_icon.size,
		},
		padding_left = 0,
		padding_right = settings.module_spacing,
	},
	label = { drawing = false },
	update_freq = 3,
})

wifi:subscribe({ "wifi_change", "routine", "system_woke" }, function()
	sbar.exec("ifconfig en0 | grep -q 'status: active' && echo 'connected' || echo 'disconnected'", function(status)
		if status:match("connected") then
			wifi:set({
				icon = { string = icons.wifi.connected },
			})
		else
			wifi:set({
				icon = { string = icons.wifi.disconnected },
			})
		end
	end)
end)
