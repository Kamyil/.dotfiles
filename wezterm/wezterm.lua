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

-- General settings - Performance optimized
config.front_end = "OpenGL" -- OpenGL is more stable and performant than WebGPU
config.audible_bell = "Disabled"
-- Disable expensive hyperlink detection
-- config.hyperlink_rules = wezterm.default_hyperlink_rules()
-- Disable ligatures and complex text shaping for better performance
-- config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- Font settings
-- config.font = wezterm.font("JetBrainsMonoNL Nerd Font Propo", { weight = "Regular" })
-- config.font = wezterm.font("JetBrainsMonoNL Nerd Font Propo", { weight = "Bold" })
-- config.font = wezterm.font("ComicShannsMono Nerd Font Propo", { weight = "Bold" })
-- config.font = wezterm.font("ComicMonoNF", { weight = "Regular" })
-- config.font = wezterm.font("ComicMono Nerd Font", { weight = "Regular" })
-- config.font = wezterm.font("Maple Mono", { weight = 700 })
config.font = wezterm.font("Berkeley Mono", { weight = 520 })
-- config.font = wezterm.font("Monocraft Nerd Font", { weight = "Regular" })
config.font_size = 14
config.text_background_opacity = 1


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
--
-- Cursor settings - Disable blinking for CPU savings
config.default_cursor_style = "SteadyBar"
config.command_palette_font_size = 14
-- config.command_palette_bg_color = "#1a1b26" -- Darker Tokyo Night background
config.force_reverse_video_cursor = true

-- Performance settings - High FPS for snappy experience
config.automatically_reload_config = true
config.enable_kitty_graphics = true -- Keep for work functionality
config.window_close_confirmation = "AlwaysPrompt"
config.custom_block_glyphs = false  -- Disable custom glyphs for performance
config.animation_fps = 120          -- Restore high FPS for snappy feel
config.max_fps = 120                -- Match animation fps
config.prefer_egl = true


-- Adjust font cell dimensions
config.adjust_window_size_when_changing_font_size = false

-- Adjust font width for different environments:
-- On work monitor:
-- config.cell_width = 1.05
-- On Mac itself:
-- config.cell_width = 1.00
-- config.line_height = 1.00
-- To disable ligatures, use:
-- config.harfbuzz_features = { "liga=0" }

-- Window decorations - Minimal for performance
config.window_decorations = "RESIZE"

-- Disable blur for performance - major CPU/GPU saver on macOS
-- config.macos_window_background_blur = 20
config.scrollback_lines = 2000 -- Reduce from 3500 to save memory
-- Disable ligatures for better performance
-- config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
config.enable_wayland = false

-- Window padding
config.window_padding = {
	left = "20",
	right = "20",
	top = "20",
	bottom = "20",
}

-- Color scheme
config.color_scheme_dirs = { "~/.config/wezterm/colors" }
config.color_scheme = "kanagawa"
-- config.color_scheme = "kanagawa-paper-ink"
-- config.color_scheme = "Kanagawa (Gogh)"
-- config.color_scheme = "Everforest Dark Hard"
-- config.color_scheme = "posterpole"
-- config.color_scheme = "Everforest Dark (Medium)"

config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.8,
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

-- Font rendering - Optimized for performance
config.freetype_load_target = "Normal"   -- Less CPU intensive than "Light"
config.freetype_render_target = "Normal" -- Simplified rendering

-- Simplified background for performance - solid color only
config.background = {
	{
		source = {
			Color = "#181616",
		},
		width = "100%",
		height = "100%",
		opacity = 0.97, -- Full opacity for better performance
	},
}

-- Merge my_own_tmux keys into config keys
config.keys = config.keys or {}

for _, my_own_tmux_config_kv_pair in ipairs(my_own_tmux.keys) do
	table.insert(config.keys, my_own_tmux_config_kv_pair)
end
for _, nvim_split_navigator_keys in ipairs(nvim_split_navigator.keys) do
	table.insert(config.keys, nvim_split_navigator_keys)
end

-- Optimized status update - reduced frequency for better performance
-- wezterm.on("update-status", function(gui_window, pane)
-- 	-- Cache tab info to avoid recalculation every update
-- 	local tabs = gui_window:mux_window():tabs()
-- 	local mid_width = 0
-- 	for idx, tab in ipairs(tabs) do
-- 		local title = tab:get_title()
-- 		mid_width = mid_width + math.floor(math.log(idx, 10)) + 1
-- 		mid_width = mid_width + 2 + #title + 1
-- 	end
-- 	local tab_width = gui_window:active_tab():get_size().cols
-- 	local max_left = tab_width / 2 - mid_width / 2
--
-- 	gui_window:set_left_status(wezterm.pad_left(" ", max_left))
-- end)

-- Simplified right status for performance
local current_workspace = nil

-- wezterm.on("update-right-status", function(window, pane)
-- 	if current_workspace then
-- 		window:set_right_status("Workspace: " .. current_workspace)
-- 	end
-- end)

-- Minimal tab formatting
-- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
-- 	return string.format(" %d: %s ", tab.tab_index + 1, tab.tab_title)
-- end)

-- Session picker functionality
wezterm.on("pick_or_create_session", function(window, pane)
	local mux = wezterm.mux
	local session_names = {}

	-- Get the names of all existing sessions
	for _, window in ipairs(mux.all_windows()) do
		table.insert(session_names, window:get_workspace())
	end

	-- Prompt the user with a fuzzy search input
	window:perform_action(
		wezterm.action.PromptInputLine({
			description = "Select or create a session:",
			action = wezterm.action_callback(function(input)
				if input and input ~= "" then
					-- Check if the session already exists
					local session_exists = false
					for _, name in ipairs(session_names) do
						if name == input then
							session_exists = true
							break
						end
					end

					if session_exists then
						-- Attach to the existing session
						mux.set_active_workspace(input)
					else
						-- Create a new session
						mux.set_active_workspace(input)
						mux.spawn_window({ workspace = input })
					end
				end
			end),
		}),
		pane
	)
end)

-- Configuration reload notification
wezterm.on("window-config-reloaded", function(window, pane)
	toast(window, "Configuration reloaded!")
end)
-- Return the configuration
return config
