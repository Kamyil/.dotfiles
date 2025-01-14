local wezterm = require("wezterm")
local kanagawa_theme_palette = require("./custom_themes/kanagawa")
-- Initialize the config builder
local config = wezterm.config_builder()
local my_own_tmux = require("./my_own_tmux")
local utils = require("./utils")
local nvim_split_navigator = require("./nvim_split_navigator")

-- General settings
-- config.enable_tab_bar = false -- Disable tabs
config.front_end = "WebGpu" -- Use WebGPU for rendering
-- config.dpi = 92
-- config.freetype_load_flags = "NO_HINTING"
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
config.audible_bell = "Disabled"

-- Font settings
config.font = wezterm.font("JetBrainsMonoNL Nerd Font Propo", { weight = "Regular" })
-- config.font = wezterm.font("JetBrainsMonoNL Nerd Font Propo", { weight = "Bold" })

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

config.font_size = 10
config.default_cursor_style = "SteadyBlock"
config.automatically_reload_config = true -- Reload the config automatically when modified
config.enable_kitty_graphics = true -- Enable support for Kitty graphics protocol
config.window_close_confirmation = "AlwaysPrompt" -- Since WezTerm workspaces do not have tmux-like living sessions in the background, we need to make our ass safe from exiting
config.custom_block_glyphs = true -- Improve rendering of block glyphs
config.animation_fps = 120 -- Increase frame rate for smoother animations
config.max_fps = 120 -- Match your display's refresh rate to save resources
config.prefer_egl = true -- Prefer to use Apple's Metal rather than OpenGL
config.use_ime = true

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
-- config.macos_window_background_blur = 0 -- Blur on macOS
config.scrollback_lines = 10000 -- Increase scrollback buffer (default is 3500)
-- config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" } -- Enable ligatures
config.enable_wayland = false -- (Mac doesn’t use Wayland but avoids auto checks)

-- Window padding
config.window_padding = {
	-- left = "3cell",
	-- right = "3cell",
	-- top = "1cell",
	bottom = "0",
}

-- Color scheme
-- config.color_scheme = "Kanagawa (Gogh)"

config.inactive_pane_hsb = {
	saturation = 1.0,
	brightness = 1.0,
}

config.colors = {
	-- The default text color
	foreground = kanagawa_theme_palette.dragonWhite,
	-- The default background color
	background = kanagawa_theme_palette.dragonBlack0,

	-- Overrides the cell background color when the current cell is occupied by the
	-- cursor and the cursor style is set to Block
	cursor_bg = kanagawa_theme_palette.dragonYellow,
	-- Overrides the text color when the current cell is occupied by the cursor
	cursor_fg = "black",
	-- Specifies the border color of the cursor when the cursor style is set to Block,
	-- or the color of the vertical or horizontal bar when the cursor style is set to
	-- Bar or Underline.
	cursor_border = kanagawa_theme_palette.dragonYellow,

	-- the foreground color of selected text
	selection_fg = "black",
	-- the background color of selected text
	selection_bg = "#fffacd",

	-- The color of the scrollbar "thumb"; the portion that represents the current viewport
	scrollbar_thumb = "#222222",

	-- The color of the split lines between panes
	split = kanagawa_theme_palette.dragonBlack3,

	ansi = {
		-- "black",
		kanagawa_theme_palette.dragonBlack2,

		-- "maroon" (redish),
		kanagawa_theme_palette.dragonRed,

		-- "green",
		kanagawa_theme_palette.dragonGreen,

		-- "olive",
		kanagawa_theme_palette.dragonGreen2,

		-- "navy" (blueish),
		kanagawa_theme_palette.dragonBlue,

		-- "purple",
		kanagawa_theme_palette.dragonPink,

		-- "teal",
		kanagawa_theme_palette.dragonAqua,

		-- "silver",
		kanagawa_theme_palette.dragonWhite,
	},

	-- Arbitrary colors of the palette in the range from 16 to 255
	-- indexed = { [136] = "#af8700" },

	-- Since: 20220319-142410-0fcdea07
	-- When the IME, a dead key or a leader key are being processed and are effectively
	-- holding input pending the result of input composition, change the cursor
	-- to this color to give a visual cue about the compose state.
	-- compose_cursor = "orange",

	-- Colors for copy_mode and quick_select
	-- available since: 20220807-113146-c2fee766
	-- In copy_mode, the color of the active text is:
	-- 1. copy_mode_active_highlight_* if additional text was selected using the mouse
	-- 2. selection_* otherwise
	copy_mode_active_highlight_bg = { Color = "orange" },
	-- use `AnsiColor` to specify one of the ansi color palette values
	-- (index 0-15) using one of the names "Black", "Maroon", "Green",
	--  "Olive", "Navy", "Purple", "Teal", "Silver", "Grey", "Red", "Lime",
	-- "Yellow", "Blue", "Fuchsia", "Aqua" or "White".
	copy_mode_active_highlight_fg = { Color = "#00FF00" },
	copy_mode_inactive_highlight_bg = { Color = "#52ad70" },
	copy_mode_inactive_highlight_fg = { Color = "White" },

	quick_select_label_bg = { Color = "peru" },
	quick_select_label_fg = { Color = "#ffffff" },
	quick_select_match_bg = { AnsiColor = "Navy" },
	quick_select_match_fg = { Color = "#ffffff" },
}

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_max_width = 128
config.bold_brightens_ansi_colors = "No"

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
	{ key = "C", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "V", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "Insert", mods = "SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
}

-- Font rendering tweaks for macOS
config.freetype_load_target = "Light" -- Finer rendering control
-- config.freetype_render_target = "HorizontalLcd"

-- Background customization
config.background = {
	{
		source = {
			-- File options for static images:
			-- File = "/Users/kamil/Desktop/Wallpapers/Catppuccin/isekai.jpg",
			-- File = "/Users/kamil/Desktop/Wallpapers/Catppuccin/misty-boat.jpg",
			-- File = "/Users/kamil/Desktop/Wallpapers/Catppuccin/dark-forest.jpg",
			-- File = "/Users/kamil/false/Wallpapers/4k/witcher_4.jpeg",
			-- File = "/Users/kamil/Desktop/Wallpapers/4k/glass_rain.jpg",
			-- File = "/Users/kamil/Desktop/Wallpapers/Kanagawa/colorful.jpg",
			-- File = "/Users/kamil/Desktop/Wallpapers/Kanagawa/great-wave.jpg",
			-- File = "/Users/kamil/Desktop/Wallpapers/Kanagawa/wp6265120-2509613833.jpg",
			File = "/Users/kamil/Desktop/Wallpapers/Kanagawa/kanagawa-minimal.jpg",
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
		},
		width = "100%",
		repeat_x = "NoRepeat",
		vertical_align = "Middle",
		repeat_y_size = "100%",
		hsb = {
			brightness = 0.007, -- Adjust brightness
			saturation = 0.90, -- Full saturation
		},
	},
	-- Darken layer to make text more contrast
	-- {
	-- 	source = {
	-- 		Color = "#16161D",
	-- 		-- Color = "#E6C384",
	-- 	},
	-- 	width = "100%",
	-- 	height = "100%",
	-- 	opacity = 0.01,
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
-- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
-- 	return string.format(" %d: %s ", tab.tab_index + 1, tab.tab_title)
-- end)

local ssh_domains = {}

for host, config in pairs(wezterm.enumerate_ssh_hosts()) do
	table.insert(ssh_domains, {
		-- the name can be anything you want; we're just using the hostname
		name = host,
		-- remote_address must be set to `host` for the ssh config to apply to it
		remote_address = host,

		-- if you don't have wezterm's mux server installed on the remote
		-- host, you may wish to set multiplexing = "None" to use a direct
		-- ssh connection that supports multiple panes/tabs which will close
		-- when the connection is dropped.

		-- multiplexing = "None",

		-- if you know that the remote host has a posix/unix environment,
		-- setting assume_shell = "Posix" will result in new panes respecting
		-- the remote current directory when multiplexing = "None".
		assume_shell = "Posix",
	})
end

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

config.ssh_domains = ssh_domains

local last_workspace = nil -- Track the last active workspace

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

-- Return the configuration
return config
