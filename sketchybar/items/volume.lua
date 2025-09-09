local sbar = require("sketchybar")

local volume = sbar.add("item", "volume", {
	position = "right",
	script = "$CONFIG_DIR/plugins/volume.sh",
})

volume:subscribe("volume_change")