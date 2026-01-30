-- Volume widget matching waybar's pulseaudio module
-- waybar: icon only with tooltip showing percentage
local sbar = require("sketchybar")
local fonts = require("fonts")
local icons = require("icons")
local settings = require("settings")

local volume = sbar.add("item", "volume", {
	position = "right",
	icon = {
		string = icons.volume._100,
		font = {
			family = fonts.font_icon.text,
			style = fonts.font_icon.style_map["Regular"],
			size = fonts.font_icon.size,
		},
		padding_left = 0,
		padding_right = settings.module_spacing,
	},
	label = { drawing = false },
})

volume:subscribe("volume_change", function(env)
	local vol = tonumber(env.INFO)
	local icon = icons.volume._0
	
	if vol > 66 then
		icon = icons.volume._100
	elseif vol > 33 then
		icon = icons.volume._66
	elseif vol > 10 then
		icon = icons.volume._33
	elseif vol > 0 then
		icon = icons.volume._10
	end
	
	volume:set({
		icon = { string = icon },
	})
end)

-- Initial volume check
sbar.exec("osascript -e 'output volume of (get volume settings)'", function(vol)
	local volume_level = tonumber(vol) or 0
	local icon = icons.volume._0
	
	if volume_level > 66 then
		icon = icons.volume._100
	elseif volume_level > 33 then
		icon = icons.volume._66
	elseif volume_level > 10 then
		icon = icons.volume._33
	elseif volume_level > 0 then
		icon = icons.volume._10
	end
	
	volume:set({
		icon = { string = icon },
	})
end)
