local wezterm = require("wezterm")
-- Initialize the config builder
local config = wezterm.config_builder()

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

-- Font settings - Berkeley Mono optimized for 1440p sharp rendering
config.font = wezterm.font("Berkeley Mono", { weight = 510 })
-- config.font = wezterm.font("JetBrainsMonoNL Nerd Font Propo", { weight = "Regular" })
-- config.font = wezterm.font("JetBrainsMonoNL Nerd Font Propo", { weight = "Bold" })
-- config.font = wezterm.font("ComicShannsMono Nerd Font Propo", { weight = "Bold" })
-- config.font = wezterm.font("ComicMonoNF", { weight = "Regular" })
-- config.font = wezterm.font("ComicMono Nerd Font", { weight = "Regular" })
-- config.font = wezterm.font("Maple Mono", { weight = 510 })
-- config.font = wezterm.font("Monocraft Nerd Font", { weight = "Regular" })
-- config.font = wezterm.font("SF Mono", { weight = "Regular" })
-- config.font = wezterm.font("BlexMono Nerd Font", { weight = "Medium" })
-- config.font = wezterm.font("FiraCode Nerd Font", { weight = "Bold" })
-- config.font = wezterm.font("GeistMono Nerd Font", { weight = 510 })
-- config.font = wezterm.font("Hack Nerd Font", { weight = "Regular" })
-- config.font = wezterm.font("RobotoMono Nerd Font", { weight = "Regular" })
-- config.font = wezterm.font("ZedMono Nerd Font")
config.font_size = 13

-- FreeType rendering optimized for 1440p sharpness
-- HorizontalLcd: best for subpixel rendering on 1440p (uses RGB ordering)
config.freetype_load_target = "HorizontalLcd"
config.prefer_egl = false  -- Improve font rendering stability
config.freetype_render_target = "HorizontalLcd"  -- Matching render target
config.freetype_interpreter_version = 38  -- Latest FreeType interpreter for best hinting
-- 1440p Display precise dimensions
config.cell_width = 1.0
config.line_height = 1.0


--
-- Cursor settings - Disable blinking for CPU savings
config.command_palette_font_size = 14
-- config.command_palette_font = wezterm.font 'Berkeley Mono'
config.command_palette_bg_color = "#1a1b26" -- Darker Tokyo Night background
config.force_reverse_video_cursor = false
config.cursor_thickness = 3
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.default_cursor_style = "SteadyBlock"

-- Performance settings - High FPS for snappy experience
config.automatically_reload_config = true
config.enable_kitty_graphics = true -- Keep for  work functionality
config.window_close_confirmation = "AlwaysPrompt"
config.custom_block_glyphs = true  -- Disable custom glyphs for performance
config.animation_fps = 120          -- Restore high FPS for snappy feel
config.max_fps = 120                -- Match animation fps


-- Adjust font cell dimensions
config.adjust_window_size_when_changing_font_size = false
-- To disable ligatures, use:
-- config.harfbuzz_features = { "liga=0" }

-- Window decorations - Minimal for performance
config.window_decorations = "RESIZE"

-- Disable blur for performance - major CPU/GPU saver on macOS
config.macos_window_background_blur = 100
config.scrollback_lines = 2000 -- Reduce from 3500 to save memory
-- Disable ligatures for better performance
-- config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
config.enable_wayland = false

-- Window padding
config.window_padding = {
	left = "30",
	right = "30",
	top = "30",
	bottom = "30",
}

-- Color scheme
-- config.color_scheme = "kanagawa-paper-ink"

local mhfu = require "colors/village".colors

config.color_schemes = {
  ["MHFU Pokke"] = {
    foreground = mhfu.fg,
    background = mhfu.bg,
    cursor_bg = mhfu.wood_light,
    cursor_fg = mhfu.bg,
    cursor_border = mhfu.wood_light,

    selection_bg = mhfu.selection,
    selection_fg = mhfu.fg,

    scrollbar_thumb = mhfu.border,
    split = mhfu.hud_blue,  -- visible split using HUD blue

    ansi = {
      mhfu.bg_alt,          -- black (wood)
      mhfu.meat_red,        -- red (well-done steak)
      mhfu.health_green,    -- green (health bar)
      mhfu.stamina_gold,    -- yellow (stamina bar)
      mhfu.quest_blue,      -- blue (quest menu)
      mhfu.rare_purple,     -- magenta (rare item)
      mhfu.snow_blue,       -- cyan (pokke snow)
      mhfu.fg,              -- white (parchment)
    },
    brights = {
      mhfu.wood_dark,       -- bright black (wood dark)
      mhfu.felyne_orange,   -- bright red (felyne kitchen)
      "#8aaa7a",            -- bright green (brighter health)
      mhfu.wood_light,      -- bright yellow (wood highlight)
      "#7a9ab0",            -- bright blue (brighter quest)
      "#9a80a0",            -- bright magenta (brighter rare)
      mhfu.ice_pale,        -- bright cyan (ice)
      "#e4d8c0",            -- bright white (lighter parchment)
    },
  },
}

config.color_scheme = "MHFU Pokke"

config.colors = {
  tab_bar = {
    background = mhfu.bg,

    active_tab = {
      bg_color = mhfu.wood_brown,
      fg_color = mhfu.fg,
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = mhfu.bg_alt,
      fg_color = mhfu.fg_dim,
    },
    inactive_tab_hover = {
      bg_color = mhfu.felyne_orange,
      fg_color = mhfu.bg,
      italic = true,
    },
    new_tab = {
      bg_color = mhfu.bg,
      fg_color = mhfu.fg_dim,
    },
    new_tab_hover = {
      bg_color = mhfu.felyne_orange,
      fg_color = mhfu.bg,
    },
  },
}
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_max_width = 256
config.bold_brightens_ansi_colors = false

-- Environment variables
config.set_environment_variables = {
	TERM = "xterm-256color", -- Set TERM environment variable
}

-- Key bindings
config.keys = {
	-- { key = "C", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
	-- { key = "V", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },
	-- { key = "Insert", mods = "SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "P", mods = "CMD|SHIFT", action = wezterm.action.ActivateCommandPalette },
}

-- Simplified background for performance - solid color only
-- config.background = {
-- 	{
-- 		source = {
-- 			-- Color = "#1F1F28",
-- 			-- Color = "#141416",
-- 			-- Color = "#1C2123",
-- 			Color = "#1C1C22",
-- 			-- Color = "#1F2122",
-- 			-- Color = "#1B1D1E"
-- 			-- Color = '#050605'
-- 		},
-- 		width = "100%",
-- 		height = "100%",
-- 		opacity = 1.0, -- Full opacity for better performance
-- 	},
-- }
config.window_background_opacity = 1.00

-- Merge my_own_tmux keys into config keys
config.keys = config.keys or {}

for _, my_own_tmux_config_kv_pair in ipairs(my_own_tmux.keys) do
	table.insert(config.keys, my_own_tmux_config_kv_pair)
end
for _, nvim_split_navigator_keys in ipairs(nvim_split_navigator.keys) do
	table.insert(config.keys, nvim_split_navigator_keys)
end


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
