local sbar = require("sketchybar")

local cpu = sbar.add("item", "cpu", {
	position = "right",
	script = "$CONFIG_DIR/plugins/cpu.sh",
	update_freq = 2,
})

cpu:subscribe("routine")