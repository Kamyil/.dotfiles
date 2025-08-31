local wezterm = require("wezterm")

-- Enhanced tmux-like functionality for WezTerm
-- Workspace Management:
--   Ctrl+p: Create new workspace (prompts for name, auto-names if empty)
--   Ctrl+Shift+P: Quick create workspace with auto-name (no prompt)
--   Ctrl+o: Switch between workspaces (fuzzy finder)
--   Ctrl+Shift+R: Rename current workspace
--   Ctrl+i: Show workspace info
--   Ctrl+f: Tmux-sessionizer (pick git repo directory and create workspace)
--   Ctrl+Shift+F: Pick any directory and create workspace

local my_own_tmux = {
	-- Counter for auto-naming workspaces
	workspace_counter = 0,

	-- Utility function to generate a good workspace name
	generate_workspace_name = function(pane)
		local cwd = pane:get_current_working_dir()
		if cwd then
			local path = cwd.file_path or ""
			local dir_name = path:match("([^/]+)/?$")
			if dir_name and dir_name ~= "" then
				return dir_name
			end
		end

		-- my_own_tmux.workspace_counter = my_own_tmux.workspace_counter + 1
		return "workspace-" .. math.random()
	end,
	-- Keybindings
	keys = {
		-- Create a tab
		{ key = "n", mods = "CTRL", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
		-- { key = "t", mods = "CTRL", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },

		-- Close the tab
		-- { key = "w", mods = "CTRL", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
		{ key = "x", mods = "CTRL", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
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
		{ key = "/",  mods = "CTRL", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
		-- Split horizontally
		{ key = "-",  mods = "CTRL", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
		{ key = "=",  mods = "CTRL", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },

		-- Switch to tabs (a.k.a. tmux windows)
		{ key = "1",  mods = "CTRL", action = wezterm.action({ ActivateTab = 0 }) },
		{ key = "2",  mods = "CTRL", action = wezterm.action({ ActivateTab = 1 }) },
		{ key = "3",  mods = "CTRL", action = wezterm.action({ ActivateTab = 2 }) },
		{ key = "4",  mods = "CTRL", action = wezterm.action({ ActivateTab = 3 }) },
		{ key = "5",  mods = "CTRL", action = wezterm.action({ ActivateTab = 4 }) },
		{ key = "6",  mods = "CTRL", action = wezterm.action({ ActivateTab = 5 }) },
		{ key = "7",  mods = "CTRL", action = wezterm.action({ ActivateTab = 6 }) },
		{ key = "8",  mods = "CTRL", action = wezterm.action({ ActivateTab = 7 }) },
		{ key = "9",  mods = "CTRL", action = wezterm.action({ ActivateTab = 8 }) },

		-- Move between panes
		{ key = "h",  mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
		{ key = "j",  mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
		{ key = "k",  mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
		{ key = "l",  mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Right" }) },

		-- Session Switching with FZF like in tmux-sessionx
		{
			key = "o",
			mods = "CTRL",
			action = wezterm.action.ShowLauncherArgs({
				flags = "FUZZY|WORKSPACES",
			}),
		},
		-- Create new workspace with optional naming
		{
			key = "p",
			mods = "CTRL",
			action = wezterm.action.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter name for new workspace (or press Enter for auto-name)" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					local workspace_name

					if line and line ~= "" then
						-- User provided a name
						workspace_name = line
					else
						-- Auto-generate name using utility function
						workspace_name = my_own_tmux.generate_workspace_name(pane)
					end

					window:perform_action(
						wezterm.action.SwitchToWorkspace({
							name = workspace_name,
						}),
						pane
					)
				end),
			}),
		},
		-- Quick create workspace with auto-name (no prompt)
		{
			key = "P",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(function(window, pane)
				local workspace_name = my_own_tmux.generate_workspace_name(pane)

				window:perform_action(
					wezterm.action.SwitchToWorkspace({
						name = workspace_name,
					}),
					pane
				)
			end),
		},
		-- Toggle second-brain notes session and back
		{
			key = "s",
			mods = "CTRL",
			action = wezterm.action.EmitEvent("toggle_second_brain"),
		},

		-- Rename current workspace
		{
			key = "R",
			mods = "CTRL|SHIFT",
			action = wezterm.action.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Blue" } },
					{ Text = "Enter new name for current workspace" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line and line ~= "" then
						local current_workspace = window:active_workspace()
						local mux = wezterm.mux

						-- Get the current workspace
						local workspace = mux.get_workspace(current_workspace)
						if workspace then
							-- Move all tabs from current workspace to new workspace
							for _, tab in ipairs(workspace:tabs()) do
								tab:move_to_workspace(line)
							end
							-- Switch to the new workspace
							window:perform_action(
								wezterm.action.SwitchToWorkspace({
									name = line,
								}),
								pane
							)
						end
					end
				end),
			}),
		},
		-- Show workspace info
		{
			key = "i",
			mods = "CTRL",
			action = wezterm.action_callback(function(window, pane)
				local workspace_name = window:active_workspace()
				local cwd = pane:get_current_working_dir()
				local path = cwd and cwd.file_path or "unknown"

				window:toast_notification("WezTerm",
					string.format("Workspace: %s\nDirectory: %s", workspace_name, path),
					nil, 3000)
			end),
		},
		-- Tmux-sessionizer: Pick directory and create workspace
		{
			key = "f",
			mods = "CTRL",
			action = wezterm.action.SpawnCommandInNewTab({
				args = {
					"bash", "-c",
					[[
						# Find git repositories in common locations
						echo "Searching for git repositories..."
						dirs=$(find ~ ~/.config ~/Documents ~/Projects ~/dev ~/Code \
							-maxdepth 3 -type d -name ".git" \
							-exec dirname "{}" \; 2>/dev/null | sort -u)
						
						if [ -z "$dirs" ]; then
							echo "No git repositories found in searched directories"
							echo "Searched: ~, ~/.config, ~/Documents, ~/Projects, ~/dev, ~/Code"
							read -p "Press Enter to close..."
							exit 1
						fi
						
						echo "Found repositories, opening selector..."
						
						# Use fzf to select directory
						selected=$(echo "$dirs" | /opt/homebrew/bin/fzf \
							--prompt='Select git repo: ' \
							--height=40% \
							--reverse \
							--preview='ls -la {}' \
							--preview-window=right:50%:wrap)
						
						if [ -n "$selected" ]; then
							# Create more descriptive workspace name using parent/project pattern
							parent_dir=$(basename "$(dirname "$selected")")
							project_dir=$(basename "$selected")
							workspace_name="${parent_dir}/${project_dir}"
							echo "Creating workspace: $workspace_name"
							echo "Directory: $selected"
							
							# Create new workspace with the selected directory
							/opt/homebrew/bin/wezterm cli spawn --new-window --workspace "$workspace_name" --cwd "$selected"
							
							echo "Created workspace: $workspace_name"
							sleep 1
						else
							echo "No directory selected"
							sleep 1
						fi
					]]
				},
			}),
		},
		-- Alternative sessionizer: Pick any directory (custom paths)
		{
			key = "m",
			mods = "CTRL",
			action = wezterm.action.SpawnCommandInNewTab({
				args = {
					"bash", "-c",
					[[
						echo "Searching for directories in custom paths..."
						
						# Find directories in specific paths (customize these)
						dirs=$(find ~/.config ~/Work/Projects \
							-maxdepth 2 -type d \
							! -path "*/.*" \
							! -path "*/node_modules" \
							! -path "*/target" \
							! -path "*/.git" \
							2>/dev/null | sort)
						
						if [ -z "$dirs" ]; then
							echo "No directories found in: ~/.config, ~/Work/Projects"
							read -p "Press Enter to close..."
							exit 1
						fi
						
						echo "Found directories, opening selector..."
						
						# Use fzf to select directory
						selected=$(echo "$dirs" | /opt/homebrew/bin/fzf \
							--prompt='Select directory: ' \
							--height=40% \
							--reverse \
							--preview='ls -la {}' \
							--preview-window=right:50%:wrap)
						
						if [ -n "$selected" ]; then
							# Create more descriptive workspace name using parent/project pattern
							parent_dir=$(basename "$(dirname "$selected")")
							project_dir=$(basename "$selected")
							workspace_name="${parent_dir}/${project_dir}"
							echo "Creating workspace: $workspace_name"
							echo "Directory: $selected"
							
							# Create new workspace with the selected directory
							/opt/homebrew/bin/wezterm cli spawn --new-window --workspace "$workspace_name" --cwd "$selected"
							
							echo "Created workspace: $workspace_name"
							sleep 1
						else
							echo "No directory selected"
							sleep 1
						fi
					]]
				},
			}),
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

	-- Auto-name workspaces based on directory when switching
	wezterm.on("update-status", function(window, pane)
		local workspace_name = window:active_workspace()

		-- Check if workspace has a generic name that should be auto-renamed
		if workspace_name and workspace_name:match("^default$") then
			local cwd = pane:get_current_working_dir()
			if cwd then
				local path = cwd.file_path or ""
				local dir_name = path:match("([^/]+)/?$")
				if dir_name and dir_name ~= "" and dir_name ~= workspace_name then
					-- Only rename if the directory name is meaningful
					window:perform_action(
						wezterm.action.SwitchToWorkspace({
							name = dir_name,
						}),
						pane
					)
				end
			end
		end
	end),

	-- Mux Server for Persistent Sessions
	default_prog = { "/usr/bin/env", "wezterm-mux-server" },
}

return my_own_tmux
