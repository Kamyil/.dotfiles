-- Hyprland 0.55+ configuration.
require("monitors")

-- Prefer native Wayland backends so applications render at the output scale.
hl.env("NIXOS_OZONE_WL", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Autostart
hl.on("hyprland.start", function()
	hl.exec_cmd("quickshell")
	hl.exec_cmd("~/.config/quickshell/wallpaper-control.sh start")
	hl.exec_cmd("bash ~/.config/hypr/exec-cursor.sh")
end)

hl.config({
	xwayland = {
		force_zero_scaling = true,
	},

	input = {
		kb_layout = "pl",
		kb_options = "caps:escape",
		follow_mouse = 1,
		repeat_rate = 50,
		repeat_delay = 300,
		sensitivity = 0.4,
		accel_profile = "adaptive",
		natural_scroll = true,
		touchpad = {
			natural_scroll = true,
			scroll_factor = 0.7,
			clickfinger_behavior = true,
			tap_to_click = true,
			tap_button_map = "lrm",
			tap_and_drag = true,
			disable_while_typing = true,
		},
	},

	cursor = {
		no_hardware_cursors = false,
	},

	general = {
		gaps_in = 4,
		gaps_out = 6,
		border_size = 1,
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

-- Keep the ThinkPad's Mac-like modifier order and swap its right Ctrl/Print Screen keys.
hl.device({
	name = "at-translated-set-2-keyboard",
	kb_file = "/home/kamil/.dotfiles/xkb/thinkpad.xkb",
})

-- The physical Print Screen key is exposed by the separate ThinkPad hotkey device.
hl.device({
	name = "thinkpad-extra-buttons",
	kb_file = "/home/kamil/.dotfiles/xkb/thinkpad.xkb",
})

-- Three-finger horizontal touchpad swipe between workspaces.
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Short 120–140ms transitions: enough motion to orient without sustained rendering.
hl.animation({ leaf = "windows", enabled = true, speed = 1.2, bezier = "default", style = "popin 98%" })
hl.animation({ leaf = "layers", enabled = true, speed = 1.2, bezier = "default", style = "fade" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.2, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.4, bezier = "default", style = "slidefade 8%" })
hl.workspace_rule({ workspace = "special:spotify", animation = "fade" })
hl.workspace_rule({ workspace = "special:chatgpt", animation = "slidefade 8%" })
hl.workspace_rule({ workspace = "special:messenger", animation = "slidefade 8%" })
hl.workspace_rule({ workspace = "special:todoist", animation = "slidefade 8%" })

hl.window_rule({
	name = "tui-float-windows",
	match = {
		class = "^(tui-float)$",
	},
	float = true,
	center = true,
	size = { "monitor_w * 0.5", "monitor_h * 0.5" },
})

-- Full application windows presented as edge-aligned overlay panels.
hl.window_rule({
	name = "spotify-side-panel",
	match = {
		class = "^(Spotify)$",
	},
	workspace = "special:spotify",
	float = true,
	size = { 520, "monitor_h * 0.94" },
	move = { 12, "monitor_h * 0.03" },
})

hl.window_rule({
	name = "chatgpt-side-panel",
	match = {
		class = "^(chrome-chatgpt.com__-Default)$",
	},
	workspace = "special:chatgpt",
	float = true,
	size = { 620, "monitor_h * 0.94" },
	move = { "monitor_w - 632", "monitor_h * 0.03" },
})

hl.window_rule({
	name = "messenger-side-panel",
	match = {
		class = "^(chrome-www.messenger.com__-Default)$",
	},
	workspace = "special:messenger",
	float = true,
	size = { 620, "monitor_h * 0.94" },
	move = { "monitor_w - 632", "monitor_h * 0.03" },
})

hl.window_rule({
	name = "todoist-side-panel",
	match = {
		class = "^(chrome-app.todoist.com__-Default)$",
	},
	workspace = "special:todoist",
	float = true,
	size = { 620, "monitor_h * 0.94" },
	move = { "monitor_w - 632", "monitor_h * 0.03" },
})

local mainMod = "SUPER"

-- Core applications
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("quickshell ipc call launcher toggle"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("quickshell ipc call picker emoji"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("quickshell ipc call picker clipboard"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd("quickshell ipc call picker image"))
-- hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("foot --app-id=tui-float nmtui"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("~/.config/hypr/toggle-side-panel.sh todoist"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("~/.config/hypr/toggle-side-panel.sh spotify"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("~/.config/hypr/toggle-side-panel.sh chatgpt"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("~/.config/hypr/toggle-side-panel.sh messenger"))

-- Window management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.config/hypr/toggle-side-panel.sh messenger"))
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

-- Resize along each axis with Alt+Shift.
local axis_resize = {
	H = { x = -50, y = 0 },
	L = { x = 50, y = 0 },
	J = { x = 0, y = 50 },
	K = { x = 0, y = -50 },
}
for key, delta in pairs(axis_resize) do
	hl.bind(
		"ALT + SHIFT + " .. key,
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
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd("quickshell ipc call session lock"))

-- Screenshots
local screenshot = hl.dsp.exec_cmd("/home/kamil/.config/hypr/omasnap.sh")
hl.bind("Print", screenshot)
hl.bind(mainMod .. " + Print", screenshot)
hl.bind(mainMod .. " + SHIFT + 4", screenshot)

hl.layer_rule({
	name = "omasnap-overlay",
	match = {
		namespace = "^omasnap$",
	},
	no_anim = true,
	animation = "none",
})

-- Keep newly-added bindings at the end: Hyprland preserves Lua callback IDs
-- across config reloads, so inserting between existing binds can remap actions.
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("quickshell ipc call tools toggle"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("quickshell ipc call focus toggle"))

-- Audio media keys, including the Sofle rotary encoder.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer --increase 5"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer --decrease 5"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer --toggle-mute"))

-- GUI file explorer for drag-and-drop workflows.
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
