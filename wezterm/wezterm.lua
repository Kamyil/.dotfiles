local wezterm = require("wezterm")
-- Initialize the config builder
local config = wezterm.config_builder()
local action = wezterm.action
local act = wezterm.action

-- Notification when the configuration is reloaded
local function toast(window, message)
	window:toast_notification("wezterm", message .. " - " .. os.date("%I:%M:%S %p"), nil, 1000)
end
local my_own_tmux = require("./my_own_tmux")
-- local utils = require("./utils")
local nvim_split_navigator = require("./nvim_split_navigator")

-- General settings
-- config.front_end = "WebGpu" -- Use WebGPU for rendering
-- config.dpi = 92
-- config.freetype_load_flags = "NO_HINTING"
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
config.audible_bell = "Disabled"

-- Font settings
-- config.font = wezterm.font("JetBrainsMonoNL Nerd Font Propo", { weight = "Regular" })
-- config.font = wezterm.font("JetBrainsMonoNL Nerd Font Propo", { weight = "Bold" })
-- config.font = wezterm.font("ComicShannsMono Nerd Font Propo", { weight = "Bold" })
-- config.font = wezterm.font("ComicMonoNF", { weight = "Regular" })
-- config.font = wezterm.font("ComicMono Nerd Font", { weight = "Regular" })
-- config.font = wezterm.font("Maple Mono", { weight = 700 })
config.font = wezterm.font("Berkeley Mono", { weight = 700 })
-- config.font = wezterm.font("Monocraft Nerd Font", { weight = "Regular" })

config.text_background_opacity = 0.7

-- Alternative fonts for testing:
--
-- config.font = wezterm.font("SF Mono", { weight = "Regular" })
-- config.font = wezterm.font("BlexMono Nerd Font", { weight = "Medium" })
-- config.font = wezterm.font("CommitMono Nerd Font", { weight = "Bold" })
-- config.font = wezterm.font("FiraCode Nerd Font", { weight = "Bold" })
-- config.font = wezterm.font("GeistMono Nerd Font", { weight = "Bold" })
-- config.font = wezterm.font("Hack Nerd Font", { weight = "Regular" })
-- config.font = wezterm.font("RobotoMono Nerd Font", { weight = "Regular" })
-- config.font = wezterm.font("ZedMono Nerd Font")

config.font_size = 13
config.automatically_reload_config = true -- Reload the config automatically when modified
config.enable_kitty_graphics = true -- Enable support for Kitty graphics protocol
config.window_close_confirmation = "AlwaysPrompt" -- Since WezTerm workspaces do not have tmux-like living sessions in the background, we need to make our ass safe from exiting
config.custom_block_glyphs = true -- Improve rendering of block glyphs
config.animation_fps = 120 -- Increase frame rate for smoother animations
config.max_fps = 120 -- Match your display's refresh rate to save resources
config.prefer_egl = true -- Prefer to use Apple's Metal rather than OpenGL

-- Adjust font cell dimensions
config.adjust_window_size_when_changing_font_size = false

-- Adjust font width for different environments:
-- On work monitor:
-- config.cell_width = 0.95
-- On Mac itself:
config.cell_width = 1.00
config.line_height = 1.00
-- To disable ligatures, use:
-- config.harfbuzz_features = { "liga=0" }

-- Window decorations
config.window_decorations = "RESIZE" -- Minimal decorations (no title bar)

-- Background opacity and blur
-- config.macos_window_background_blur = 20 -- Blur on macOS
config.scrollback_lines = 3500 -- Increase scrollback buffer (default is 3500)
-- config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" } -- Enable ligatures
config.enable_wayland = false -- (Mac doesn’t use Wayland but avoids auto checks)

-- Window padding
config.window_padding = {
	left = "0",
	right = "0",
	top = "0",
	bottom = "0",
}

-- Color scheme
config.color_scheme = "kanagawa-paper-ink"
-- config.color_scheme = "Kanagawa (Gogh)"
-- config.color_scheme = "Kanagawa (Gogh)"
-- config.color_scheme = "Everforest Dark Hard"
-- config.color_scheme = "posterpole"

config.color_scheme_dirs = { "~/.config/wezterm/colors" }
-- config.color_scheme = "Everforest Dark (Medium)"

config.inactive_pane_hsb = {
	saturation = 1.0,
	brightness = 1.0,
}

config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_max_width = 128
config.bold_brightens_ansi_colors = false

-- Environment variables
-- config.set_environment_variables = {
-- 	TERM = "xterm-256color", -- Set TERM environment variable
-- }

-- Mouse bindings
config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

-- Key bindings
config.keys = {
	-- { key = "C", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
	-- { key = "V", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },
	-- { key = "Insert", mods = "SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
}

-- Font rendering tweaks for macOS
config.freetype_load_target = "Light" -- Finer rendering control
-- config.freetype_render_target = "HorizontalLcd"

-- Background customization
config.background = {
	{
		source = {
			Color = "#101010",
		},
		width = "100%",
		height = "100%",
		opacity = 1,
	},
	-- 	{
	-- 		source = {
	-- File options for static images:
	-- File = "/Users/kamil/Desktop/Wallpapers/Catppuccin/isekai.jpg",
	-- File = "/Users/kamil/Desktop/Wallpapers/Catppuccin/misty-boat.jpg",
	-- File = "/Users/kamil/Desktop/Wallpapers/Catppuccin/dark-forest.jpg",
	-- File = "/Users/kamil/false/Wallpapers/4k/witcher_4.jpeg",
	-- File = "/Users/kamil/Desktop/Wallpapers/4k/glass_rain.jpg",
	-- File = "/Users/kamil/Desktop/Wallpapers/Kanagawa/colorful.jpg",
	-- File = "/Users/kamil/Desktop/Wallpapers/Kanagawa/great-wave.jpg",
	-- File = "/Users/kamil/Desktop/Wallpapers/Kanagawa/wp6265120-2509613833.jpg",
	-- File = "/Users/kamil/Desktop/Wallpapers/Kanagawa/kanagawa-minimal.jpg",
	-- File = "/Users/kamil/Desktop/Wallpapers/everforest/windows-11-green.jpg",
	-- File = "/Users/kamil/Desktop/Wallpapers/everforest/wooden-stairs.jpeg",
	-- File = "/Users/kamil/Desktop/Wallpapers/everforest/zelda-forest.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/Kanagawa/black-and-red.jpg",
	-- File = "/Users/kamil/Desktop/Wallpapers/Kanagawa/moon-lights-4k-art.jpg",

	-- File options for GIFs:
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/witcher.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/shy-away.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/cyberpunk.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/cyberpunk2.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/superman.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/lofi1.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/city.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/some_weird_energy.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/some_weird_energy_2.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/trees.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/synthwave.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/sun-water.gif",
	-- File = "/Users/kamil/Desktop/Wallpapers/gif/ambient.gif",
	-- 	},
	-- 	width = "100%",
	-- 	repeat_x = "NoRepeat",
	-- 	vertical_align = "Middle",
	-- 	repeat_y_size = "100%",
	-- 	hsb = {
	-- 		brightness = 0.029, -- Adjust brightness
	-- 		saturation = 0.90, -- Full saturation
	-- 	},
	-- },
	-- Darken layer to make text more contrast
	-- {
	-- 	source = {
	-- 		Color = "#16161D",
	-- 		-- Color = "#E6C384",
	-- 	},
	-- 	width = "100%",
	-- 	height = "100%",
	-- 	opacity = 0.00,
	-- },
}

-- Merge my_own_tmux keys into config keys
config.keys = config.keys or {}

for _, my_own_tmux_config_kv_pair in ipairs(my_own_tmux.keys) do
	table.insert(config.keys, my_own_tmux_config_kv_pair)
end
for _, nvim_split_navigator_keys in ipairs(nvim_split_navigator.keys) do
	table.insert(config.keys, nvim_split_navigator_keys)
end

-- Center tab bar
wezterm.on("update-status", function(gui_window, pane)
	local tabs = gui_window:mux_window():tabs()
	local mid_width = 0
	for idx, tab in ipairs(tabs) do
		local title = tab:get_title()
		mid_width = mid_width + math.floor(math.log(idx, 10)) + 1
		mid_width = mid_width + 2 + #title + 1
	end
	local tab_width = gui_window:active_tab():get_size().cols
	local max_left = tab_width / 2 - mid_width / 2

	gui_window:set_left_status(wezterm.pad_left(" ", max_left))
	-- Ensure the right status isn't cleared here
end)

local current_workspace = nil

wezterm.on("workspace-changed", function(window, pane, workspace)
	current_workspace = workspace
	window:set_right_status("Workspace: " .. workspace)
end)

wezterm.on("update-right-status", function(window, pane)
	if current_workspace then
		window:set_right_status("Workspace: " .. current_workspace)
	end
end)
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	return string.format(" %d: %s ", tab.tab_index + 1, tab.tab_title)
end)

local ssh_domains = {}

-- for host, config in pairs(wezterm.enumerate_ssh_hosts()) do
-- 	table.insert(ssh_domains, {
-- 		-- the name can be anything you want; we're just using the hostname
-- 		name = host,
-- 		-- remote_address must be set to `host` for the ssh config to apply to it
-- 		remote_address = host,
--
-- 		-- if you don't have wezterm's mux server installed on the remote
-- 		-- host, you may wish to set multiplexing = "None" to use a direct
-- 		-- ssh connection that supports multiple panes/tabs which will close
-- 		-- when the connection is dropped.
--
-- 		-- multiplexing = "None",
--
-- 		-- if you know that the remote host has a posix/unix environment,
-- 		-- setting assume_shell = "Posix" will result in new panes respecting
-- 		-- the remote current directory when multiplexing = "None".
-- 		assume_shell = "Posix",
-- 	})
-- end

-- wezterm.on("pick_or_create_session", function(window, pane)
-- 	local mux = wezterm.mux
-- 	local session_names = {}
--
-- 	-- Get the names of all existing sessions
-- 	for _, window in ipairs(mux.all_windows()) do
-- 		table.insert(session_names, window:get_workspace())
-- 	end
--
-- 	-- Prompt the user with a fuzzy search input
-- 	window:perform_action(
-- 		wezterm.action.PromptInputLine({
-- 			description = "Select or create a session:",
-- 			action = wezterm.action_callback(function(input)
-- 				if input and input ~= "" then
-- 					-- Check if the session already exists
-- 					local session_exists = false
-- 					for _, name in ipairs(session_names) do
-- 						if name == input then
-- 							session_exists = true
-- 							break
-- 						end
-- 					end
--
-- 					if session_exists then
-- 						-- Attach to the existing session
-- 						mux.set_active_workspace(input)
-- 					else
-- 						-- Create a new session
-- 						mux.set_active_workspace(input)
-- 						mux.spawn_window({ workspace = input })
-- 					end
-- 				end
-- 			end),
-- 		}),
-- 		pane
-- 	)
-- end)

-- wezterm.on("toggle_second_brain", )

-- config.ssh_domains = ssh_domains
--
-- local last_workspace = nil -- Track the last active workspace

wezterm.on("toggle_second_brain", function(window, pane)
	local mux = wezterm.mux
	local current_workspace = mux.get_active_workspace()

	if current_workspace == "second-brain" then
		-- Switch back to the last workspace
		if last_workspace then
			print("Switching back to:", last_workspace)
			mux.set_active_workspace(last_workspace)
		end
	else
		-- Save the current workspace
		last_workspace = current_workspace

		-- Check if the 'second-brain' workspace exists
		local existing_workspaces = mux.get_workspace_names()
		local second_brain_exists = false
		for _, name in ipairs(existing_workspaces) do
			if name == "second-brain" then
				second_brain_exists = true
				break
			end
		end

		-- Create 'second-brain' if it doesn't exist
		if not second_brain_exists then
			print("Creating new workspace: second-brain in ~/second-brain")
			mux.spawn_window({
				workspace = "second-brain",
				cwd = wezterm.home_dir .. "/second-brain && nvim .",
			})
		end

		-- Switch to the 'second-brain' workspace
		print("Switching to: second-brain")
		mux.set_active_workspace("second-brain")
	end
end)
--
wezterm.on("window-config-reloaded", function(window, pane)
	toast(window, "Configuration reloaded!")
end)

-- Return the configuration
return config
