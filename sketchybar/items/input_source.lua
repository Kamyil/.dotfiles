local sbar = require("sketchybar")

local input_source = sbar.add("item", "input_source", {
	position = "right",
	script = "$CONFIG_DIR/plugins/input_source.sh",
	update_freq = 2,
})

input_source:subscribe("routine")