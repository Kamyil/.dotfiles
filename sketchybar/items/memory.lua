-- Memory widget matching waybar's memory module
-- waybar: "format": "󰘚 {used:0.1f}G/{total:0.1f}G"
local sbar = require("sketchybar")
local fonts = require("fonts")
local icons = require("icons")
local settings = require("settings")

local memory = sbar.add("item", "memory", {
	position = "right",
	icon = {
		string = icons.memory,
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

memory:subscribe({ "routine", "system_woke" }, function()
	-- Get memory info on macOS using vm_stat and sysctl
	sbar.exec("vm_stat | grep 'Pages used' | awk '{print $3}' | sed 's/\\.//'", function(pages_used)
		sbar.exec("sysctl -n hw.memsize", function(total_bytes)
			local pages = tonumber(pages_used) or 0
			local total = tonumber(total_bytes) or 0
			local page_size = 4096
			
			local used_mb = (pages * page_size) / 1024 / 1024
			local total_mb = total / 1024 / 1024
			
			local used_gb = used_mb / 1024
			local total_gb = total_mb / 1024
			
			memory:set({
				label = string.format("%.1fG/%.1fG", used_gb, total_gb),
			})
		end)
	end)
end)
