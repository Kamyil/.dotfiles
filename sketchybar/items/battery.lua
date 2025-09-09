local sbar = require("sketchybar")

local battery = sbar.add("item", "battery", {
	position = "right",
	script = "$CONFIG_DIR/plugins/battery.sh",
	update_freq = 120,
})

battery:subscribe({ "power_source_change", "system_woke", "routine" })