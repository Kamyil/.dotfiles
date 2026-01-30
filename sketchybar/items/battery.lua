-- Battery widget matching waybar's battery module
-- waybar: "{capacity}% {icon}" with various states
local sbar = require("sketchybar")
local fonts = require("fonts")
local icons = require("icons")
local settings = require("settings")

local battery = sbar.add("item", "battery", {
	position = "right",
	icon = {
		string = icons.battery._100,
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
		padding_right = 0,
	},
	update_freq = 60,
})

local function get_battery_info()
	sbar.exec("pmset -g batt | grep -Eo '\\d+%' | head -1 | cut -d% -f1", function(percentage)
		sbar.exec("pmset -g batt | grep -q 'AC Power' && echo 'charging' || echo 'discharging'", function(charging)
			local percent = tonumber(percentage) or 0
			local is_charging = charging:match("charging")
			
			local icon
			if is_charging then
				icon = icons.battery.charging
			elseif percent >= 90 then
				icon = icons.battery._100
			elseif percent >= 70 then
				icon = icons.battery._75
			elseif percent >= 50 then
				icon = icons.battery._50
			elseif percent >= 20 then
				icon = icons.battery._25
			else
				icon = icons.battery._0
			end
			
			battery:set({
				icon = { string = icon },
				label = percent .. "%",
			})
		end)
	end)
end

battery:subscribe({ "power_source_change", "system_woke", "routine" }, get_battery_info)

-- Initial battery check
get_battery_info()
