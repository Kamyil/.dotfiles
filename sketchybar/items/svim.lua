local sbar = require("sketchybar")

local svim = sbar.add("item", "svim", {
	position = "right",
	script = "$CONFIG_DIR/plugins/svim.sh",
	update_freq = 2,
})

svim:subscribe("routine")