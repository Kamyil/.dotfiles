-- ~/.config/wezterm/quickcli.lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- quake-mode styling (you can tweak position/size here too)
config.window_decorations = "RESIZE"
-- no tabs, no bells & whistles
config.enable_tab_bar = false
config.window_frame = {
	font_size = 12.0,
}
-- optional: a bit of padding so it doesn't hug the edges
config.window_padding = {
	left = 4,
	right = 4,
	top = 4,
	bottom = 4,
}

-- when I run it this way it seems my .zshrc was not read though
-- Try adding -l to zsh parameters.
-- spawn an interactive login shell, run `sd`, then drop to your prompt
config.default_prog = {
	-- absolute path is safest
	"/bin/zsh",
	"-i", -- interactive (loads ~/.zshrc)
	"-l", -- login (loads ~/.zprofile, but with -i you get ~/.zshrc too)
	"-c",
	"sd", -- run your alias command
}

return config
-- run your launcher instead of a shell

-- TODO: Change it when Launchtty becomes compiled project instead of simple alias
-- config.default_prog = { os.getenv("HOME") .. "/bin/launchtty" }
