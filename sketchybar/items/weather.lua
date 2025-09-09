local sbar = require("sketchybar")

local weather = sbar.add("item", "weather", {
	position = "right",
	script = "$CONFIG_DIR/plugins/weather.sh",
	update_freq = 1800, -- 30 minutes
})

weather:subscribe({ "forced", "routine" })