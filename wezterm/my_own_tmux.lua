local wezterm = require("wezterm")

-- Inline projectifier functionality
local function discover_projects()
	local projects = {}
	local projects_dir = wezterm.home_dir .. "/.dotfiles/wezterm/projects"

	-- Load projects directly using dofile (avoid wezterm.read_dir)
	local project_files = {
		"simple_project.lua",
		"dotfiles.lua",
		"fullstack_example.lua",
		"complex_layout.lua"
	}

	for _, filename in ipairs(project_files) do
		local project_file = projects_dir .. "/" .. filename
		local success, config = pcall(dofile, project_file)
		if success and config and config.name then
			config.filename = filename:gsub("%.lua$", "")
			config.display_name = config.name or config.filename
			config.root_dir = config.root_dir or wezterm.home_dir
			table.insert(projects, config)
		end
	end

	return projects
end

-- Build workspace from project configuration
local function build_workspace(window, pane, project_config)
	local workspace_name = project_config.name
	local root_dir = project_config.root_dir:gsub("^~/", wezterm.home_dir .. "/")

	-- Debug info
	window:toast_notification("WezTerm", "Building workspace: " .. workspace_name, nil, 2000)
	if project_config.tabs then
		window:toast_notification("WezTerm", "Found " .. #project_config.tabs .. " tabs to create", nil, 2000)
	else
		window:toast_notification("WezTerm", "ERROR: No tabs found in project config!", nil, 3000)
		return
	end

	-- Switch to workspace and configure first tab properly
	local first_tab_config = project_config.tabs[1]
	local first_command = { "zsh" }

	if first_tab_config and first_tab_config.panes and #first_tab_config.panes > 0 then
		local first_pane = first_tab_config.panes[1]
		if first_pane.command then
			first_command = { "zsh", "-c", first_pane.command .. "; exec zsh" }
		end
	end

	-- Switch to workspace with the first tab's command
	window:perform_action(
		wezterm.action.SwitchToWorkspace({
			name = workspace_name,
			spawn = {
				args = first_command,
				cwd = root_dir,
			},
		}),
		pane
	)

	-- Set title for first tab immediately with debug
	if first_tab_config then
		local current_tab = window:active_tab()
		if current_tab then
			current_tab:set_title(first_tab_config.name or "Tab 1")
			window:toast_notification("WezTerm", "Set first tab title: " .. (first_tab_config.name or "Tab 1"), nil, 1500)
		end
	end

	-- Create remaining tabs in the NEW workspace
	for i = 2, #project_config.tabs do
		local tab_config = project_config.tabs[i]
		local command_to_run = { "zsh" }

		if tab_config.panes and #tab_config.panes > 0 then
			local first_pane = tab_config.panes[1]
			if first_pane.command then
				command_to_run = { "zsh", "-c", first_pane.command .. "; exec zsh" }
			end
		end

		window:perform_action(
			wezterm.action.SpawnCommandInNewTab({
				args = command_to_run,
				cwd = root_dir,
			}),
			pane
		)

		-- Set tab title immediately with debug
		local current_tab = window:active_tab()
		if current_tab and tab_config.name then
			current_tab:set_title(tab_config.name)
			window:toast_notification("WezTerm", "Set tab " .. i .. " title: " .. tab_config.name, nil, 1500)
		end
	end

	-- Switch back to first tab
	window:perform_action(wezterm.action.ActivateTab(0), pane)
	window:toast_notification("WezTerm", "Projectifier completed!", nil, 2000)
end

-- Enhanced tmux-like functionality for WezTerm
-- Workspace Management:
--   Ctrl+p: Create new workspace (prompts for name, auto-names if empty)
--   Ctrl+Shift+P: Quick create workspace with auto-name (no prompt)
--   Ctrl+o: Switch between workspaces (fuzzy finder)
--   Ctrl+Shift+R: Rename current workspace
--   Ctrl+i: Show workspace info
--   Ctrl+f: Tmux-sessionizer (pick git repo directory and create workspace)
--   Ctrl+m: Custom directory sessionizer
--   Ctrl+t: Projectifier (select project and build workspace layout)

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
		{ key = "\\", mods = "CTRL",       action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
		{ key = "/",  mods = "CTRL",       action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
		-- Split horizontally
		{ key = "-",  mods = "CTRL",       action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
		{ key = "=",  mods = "CTRL",       action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },

		-- Rotate panes (swap positions and/or toggle between horizontal/vertical layouts)
		{ key = "w",  mods = "CTRL",       action = wezterm.action.RotatePanes("Clockwise") },
		{ key = "W",  mods = "CTRL|SHIFT", action = wezterm.action.RotatePanes("CounterClockwise") },

		-- Switch to tabs (a.k.a. tmux windows)
		{ key = "1",  mods = "CTRL",       action = wezterm.action({ ActivateTab = 0 }) },
		{ key = "2",  mods = "CTRL",       action = wezterm.action({ ActivateTab = 1 }) },
		{ key = "3",  mods = "CTRL",       action = wezterm.action({ ActivateTab = 2 }) },
		{ key = "4",  mods = "CTRL",       action = wezterm.action({ ActivateTab = 3 }) },
		{ key = "5",  mods = "CTRL",       action = wezterm.action({ ActivateTab = 4 }) },
		{ key = "6",  mods = "CTRL",       action = wezterm.action({ ActivateTab = 5 }) },
		{ key = "7",  mods = "CTRL",       action = wezterm.action({ ActivateTab = 6 }) },
		{ key = "8",  mods = "CTRL",       action = wezterm.action({ ActivateTab = 7 }) },
		{ key = "9",  mods = "CTRL",       action = wezterm.action({ ActivateTab = 8 }) },

		-- Move between panes
		{ key = "h",  mods = "CTRL",       action = wezterm.action({ ActivatePaneDirection = "Left" }) },
		{ key = "j",  mods = "CTRL",       action = wezterm.action({ ActivatePaneDirection = "Down" }) },
		{ key = "k",  mods = "CTRL",       action = wezterm.action({ ActivatePaneDirection = "Up" }) },
		{ key = "l",  mods = "CTRL",       action = wezterm.action({ ActivatePaneDirection = "Right" }) },

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
		-- Projectifier: Pick project and build workspace layout
		{
			key = "t",
			mods = "CTRL",
			action = wezterm.action_callback(function(window, pane)
				window:toast_notification("WezTerm", "Step 1: Loading projects...", nil, 2000)

				local projects = discover_projects()
				window:toast_notification("WezTerm", "Step 2: Found " .. #projects .. " projects", nil, 2000)

				if #projects == 0 then
					window:toast_notification("WezTerm", "No projects found!", nil, 3000)
					return
				end

				-- Build choices
				local choices = {}
				for _, project in ipairs(projects) do
					table.insert(choices, {
						id = project.filename,
						label = project.display_name,
					})
				end

				window:toast_notification("WezTerm", "Step 3: Built " .. #choices .. " choices", nil, 2000)

				-- Debug: Check first project structure
				if projects[1] then
					local debug_info = "First project: " .. projects[1].display_name
					if projects[1].tabs then
						debug_info = debug_info .. " | Tabs: " .. #projects[1].tabs
					else
						debug_info = debug_info .. " | No tabs found!"
					end
					window:toast_notification("WezTerm", debug_info, nil, 3000)
				end

				-- Try to show InputSelector
				window:perform_action(
					wezterm.action.InputSelector({
						title = "Select Project",
						choices = choices,
						fuzzy = true,
						action = wezterm.action_callback(function(child_window, child_pane, id, label)
							if not id then
								child_window:toast_notification("WezTerm", "Canceled", nil, 1000)
								return
							end

							child_window:toast_notification("WezTerm", "Selected: " .. label, nil, 1000)

							-- Find the selected project
							for _, project in ipairs(projects) do
								if project.filename == id then
									child_window:toast_notification("WezTerm",
										"Building project: " .. project.display_name, nil, 2000)

									-- Build full workspace with tabs and panes
									build_workspace(child_window, child_pane, project)
									return
								end
							end

							child_window:toast_notification("WezTerm", "Project not found: " .. id, nil, 2000)
						end),
					}),
					pane
				)
			end),
		},
		-- { key = "d", mods = "CTRL", action = wezterm.action.ShowDebugOverlay },
	},
}

-- Event handlers (must be outside the module table to be registered globally)
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- RESPECT EXPLICIT TAB TITLES: Use tab.tab_title if it was explicitly set
	local base_title
	if tab.tab_title and tab.tab_title ~= "" then
		-- Use explicitly set title (from our projectifier!)
		base_title = tab.tab_title
	else
		-- Fall back to pane title only if no explicit title was set
		base_title = tab.active_pane.title
	end

	-- Check for zoom status
	local zoom_icon = ""
	for _, pane in ipairs(tab.panes) do
		if pane.is_zoomed then
			zoom_icon = " 🔍"
			break
		end
	end

	local title = string.format(" %d: %s%s ", tab.tab_index + 1, base_title, zoom_icon)

	if tab.is_active then
		return {
			{ Background = { Color = "#B98D7B" } },
			{ Foreground = { Color = "#000" } },
			{ Text = title },
		}
	else
		return {
			{ Background = { Color = "#201F27" } },
			{ Foreground = { Color = "#434852" } },
			{ Text = title },
		}
	end
end)

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
end)

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
end)

-- Add mux server configuration to the module
my_own_tmux.default_prog = { "/usr/bin/env", "wezterm-mux-server" }

return my_own_tmux
