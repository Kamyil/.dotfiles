local sbar = require("sketchybar")

local wifi = sbar.add("item", "wifi", {
	position = "right",
	script = "$CONFIG_DIR/plugins/wifi.sh",
	update_freq = 5,
})

wifi:subscribe({ "wifi_change", "routine" })