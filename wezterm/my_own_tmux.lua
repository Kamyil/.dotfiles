local wezterm = require("wezterm")

local my_own_tmux = {
	-- Keybindings
	keys = {
		-- Create a tab
		{ key = "n", mods = "CTRL", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
		-- { key = "t", mods = "CTRL", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },

		-- Close the tab
		{ key = "w", mods = "CTRL", action = wezterm.action({ CloseCurrentPane = { confirm = false } }) },
		{ key = "x", mods = "CTRL", action = wezterm.action({ CloseCurrentPane = { confirm = false } }) },
		{
			mods = "CTRL",
			key = "z",
			action = wezterm.action.TogglePaneZoomState,
		},
		-- activate copy (a.k.a VISUAL) mode or vim mode
		{
			key = "v",
			mods = "CTRL",
			action = wezterm.action.ActivateCopyMode,
		},

		-- Rename tab
		{
			key = "r",
			mods = "CTRL",
			action = wezterm.action.PromptInputLine({
				description = "Enter new name for tab",
				action = wezterm.action_callback(function(window, pane, line)
					-- line will be `nil` if they hit escape without entering anything
					-- An empty string if they just hit enter
					-- Or the actual line of text they wrote
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},

		-- Split vertically
		{ key = "\\", mods = "CTRL", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
		{ key = "/", mods = "CTRL", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
		-- Split horizontally
		{ key = "-", mods = "CTRL", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
		{ key = "=", mods = "CTRL", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },

		-- Switch to tabs (a.k.a. tmux windows)
		{ key = "1", mods = "CTRL", action = wezterm.action({ ActivateTab = 0 }) },
		{ key = "2", mods = "CTRL", action = wezterm.action({ ActivateTab = 1 }) },
		{ key = "3", mods = "CTRL", action = wezterm.action({ ActivateTab = 2 }) },
		{ key = "4", mods = "CTRL", action = wezterm.action({ ActivateTab = 3 }) },
		{ key = "5", mods = "CTRL", action = wezterm.action({ ActivateTab = 4 }) },
		{ key = "6", mods = "CTRL", action = wezterm.action({ ActivateTab = 5 }) },
		{ key = "7", mods = "CTRL", action = wezterm.action({ ActivateTab = 6 }) },
		{ key = "8", mods = "CTRL", action = wezterm.action({ ActivateTab = 7 }) },
		{ key = "9", mods = "CTRL", action = wezterm.action({ ActivateTab = 8 }) },

		-- Move between panes
		{ key = "h", mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
		{ key = "j", mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
		{ key = "k", mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
		{ key = "l", mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Right" }) },

		-- Session Switching with FZF like in tmux-sessionx
		{
			key = "o",
			mods = "CTRL",
			action = wezterm.action.ShowLauncherArgs({
				flags = "FUZZY|WORKSPACES",
			}),
		},
		-- Prompt for a name to use for a new workspace and switch to it.
		{
			key = "p",
			mods = "CTRL",
			action = wezterm.action.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter name for new workspace" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					-- line will be `nil` if they hit escape without entering anything
					-- An empty string if they just hit enter
					-- Or the actual line of text they wrote
					if line then
						window:perform_action(
							wezterm.action.SwitchToWorkspace({
								name = line,
							}),
							pane
						)
					end
				end),
			}),
		},
		-- Toggle second-brain notes session and back
		{
			key = "s",
			mods = "CTRL",
			action = wezterm.action.EmitEvent("toggle_second_brain"),
		},

		-- { key = "d", mods = "CTRL", action = wezterm.action.ShowDebugOverlay },
	},

	-- 1-Based Indexing
	--
	-- This function returns the suggested title for a tab.

	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		-- It prefers the title that was set via `tab:set_title()`
		-- or `wezterm cli set-tab-title`, but falls back to the
		-- title of the active pane in that tab.
		local tab_title = function(tab_info)
			return string.format(" %d: %s ", tab.tab_index + 1, tab.active_pane.title)
		end

		local title = tab_title(tab)
		if tab.is_active then
			return {
				{ Background = { Color = "#E6C384" } },
				{ Foreground = { Color = "#000" } },
				{ Text = " " .. title .. " " },
			}
			-- else
			-- 	return {
			-- 		{ Background = { Color = "#201F27" } },
			-- 		{ Foreground = { Color = "#2A2937" } },
			-- 		{ Text = " " .. title .. " " },
			-- 	}
		end
	end),
	--
	wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
		local zoomed = ""
		if tab.active_pane.is_zoomed then
			zoomed = "[Z] "
		end

		local index = ""
		if #tabs > 1 then
			index = string.format("[%d/%d] ", tab.tab_index + 1, #tabs)
		end

		return zoomed .. index .. tab.active_pane.title
	end),

	-- Mux Server for Persistent Sessions
	default_prog = { "/usr/bin/env", "wezterm-mux-server" },
}

return my_own_tmux
