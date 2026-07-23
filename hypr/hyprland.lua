-- Hyprland 0.55+ configuration.
require("monitors")

-- Prefer native Wayland backends so applications render at the output scale.
hl.env("NIXOS_OZONE_WL", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Autostart
hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("dunst")
	hl.exec_cmd("swaybg -c '#000000'")
	hl.exec_cmd("bash ~/.config/hypr/exec-cursor.sh")
	hl.exec_cmd("hypridle -c ~/.config/hypr/hypridle.conf")
end)

hl.config({
	xwayland = {
		force_zero_scaling = true,
	},

	input = {
		kb_layout = "pl",
		kb_options = "lv3:lalt_switch,caps:escape",
		follow_mouse = 1,
		repeat_rate = 50,
		repeat_delay = 300,
		sensitivity = 0.6875,
		natural_scroll = true,
		touchpad = {
			natural_scroll = true,
		},
	},

	cursor = {
		no_hardware_cursors = false,
	},

	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 0,
		col = {
			active_border = "rgba(464645FF)",
			inactive_border = "rgba(46464533)",
		},
		layout = "dwindle",
	},

	decoration = {
		rounding = 0,
		blur = {
			enabled = false,
		},
		shadow = {
			enabled = false,
		},
	},

	animations = {
		enabled = false,
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
})

hl.window_rule({
	name = "tui-float-windows",
	match = {
		class = "^(tui-float)$",
	},
	float = true,
	center = true,
	size = { "monitor_w * 0.5", "monitor_h * 0.5" },
})

local mainMod = "SUPER"

-- Core applications
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("fuzzel"))
-- hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("foot --app-id=tui-float nmtui"))
-- hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("foot --app-id=tui-float bluetuith"))

-- Window management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

-- Focus movement (matching aerospace cmd-hjkl)
for key, direction in pairs({ H = "l", J = "d", K = "u", L = "r" }) do
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = direction }))
end

-- Window resizing (matching aerospace cmd-alt-hjkl)
local resize = {
	H = { x = 50, y = 0 },
	J = { x = 0, y = -50 },
	K = { x = 0, y = 50 },
	L = { x = -50, y = 0 },
}
for key, delta in pairs(resize) do
	hl.bind(
		mainMod .. " + ALT + " .. key,
		hl.dsp.window.resize({
			x = delta.x,
			y = delta.y,
			relative = true,
		})
	)
end

-- Move windows (matching aerospace cmd-shift-hjkl)
for key, direction in pairs({ H = "l", J = "d", K = "u", L = "r" }) do
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

-- Move current workspace between monitors (matching cmd+< and cmd+>)
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.workspace.move({ monitor = "-1" }))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.workspace.move({ monitor = "+1" }))

-- Switch workspaces and move windows to workspaces.
for workspace = 1, 10 do
	local key = workspace % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
	hl.bind("CTRL + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

-- Reload config (matching aerospace cmd-alt-r)
hl.bind(mainMod .. " + ALT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Lock screen
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd("hyprlock"))

-- Screenshots
local screenshot = hl.dsp.exec_cmd([[env QT_QPA_PLATFORM=wayland QT_SCREEN_SCALE_FACTORS="1;1" flameshot gui]])
hl.bind("Print", screenshot)
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("flameshot gui"))
hl.bind(mainMod .. " + SHIFT + 4", screenshot)
