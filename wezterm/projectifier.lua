local wezterm = require("wezterm")

local projectifier = {}

-- Path to project configurations
projectifier.projects_dir = wezterm.home_dir .. "/.dotfiles/wezterm/projects"

-- Utility function to expand home directory in paths
local function expand_path(path)
	if path:match("^~/") then
		return wezterm.home_dir .. "/" .. path:sub(3)
	end
	return path
end

-- Load a single project configuration
function projectifier.load_project_config(project_file)
	local success, config = pcall(dofile, project_file)
	if not success then
		wezterm.log_error("Failed to load project config: " .. project_file .. " - " .. (config or "unknown error"))
		return nil
	end

	-- Validate required fields
	if not config.name then
		wezterm.log_error("Project config missing 'name' field: " .. project_file)
		return nil
	end

	-- Set defaults
	config.root_dir = config.root_dir or wezterm.home_dir
	config.tabs = config.tabs or {}

	return config
end

-- Discover all project configurations
function projectifier.discover_projects()
	local projects = {}

	-- Check if projects directory exists
	local success, entries, err = wezterm.read_dir(projectifier.projects_dir)
	if not success then
		wezterm.log_error("Cannot read projects directory: " ..
			projectifier.projects_dir .. " - " .. (err or "unknown error"))
		return projects
	end

	-- Load all .lua files in projects directory
	for _, entry in ipairs(entries) do
		if entry.name:match("%.lua$") then
			local project_file = projectifier.projects_dir .. "/" .. entry.name
			local config = projectifier.load_project_config(project_file)
			if config then
				-- Use filename as fallback name
				config.filename = entry.name:gsub("%.lua$", "")
				config.display_name = config.name or config.filename
				table.insert(projects, config)
			end
		end
	end

	return projects
end

-- Build workspace from project configuration
function projectifier.build_workspace(window, pane, project_config)
	local workspace_name = project_config.name
	local root_dir = expand_path(project_config.root_dir)

	wezterm.log_info("Building workspace: " .. workspace_name)
	wezterm.log_info("Root directory: " .. root_dir)

	-- Switch to or create workspace
	window:perform_action(
		wezterm.action.SwitchToWorkspace({
			name = workspace_name,
			spawn = {
				cwd = root_dir,
			},
		}),
		pane
	)

	-- Wait a moment for workspace to be created
	wezterm.sleep_ms(100)

	-- Build each tab
	for tab_index, tab_config in ipairs(project_config.tabs) do
		local tab_name = tab_config.name or ("Tab " .. tab_index)
		local tab_dir = tab_config.dir and (root_dir .. "/" .. tab_config.dir) or root_dir
		local panes = tab_config.panes or { { command = tab_config.command } }

		-- Create tab (first tab reuses existing, others spawn new)
		if tab_index > 1 then
			window:perform_action(
				wezterm.action.SpawnTab({
					CurrentPaneDomain = {
						cwd = tab_dir,
					},
				}),
				pane
			)
		else
			-- Set directory for first tab
			window:perform_action(
				wezterm.action.SpawnCommandInNewTab({
					args = { "bash", "-c", "cd '" .. tab_dir .. "' && exec $SHELL" },
				}),
				pane
			)
		end

		-- Set tab title
		wezterm.sleep_ms(50)
		local current_tab = window:active_tab()
		if current_tab then
			current_tab:set_title(tab_name)
		end

		-- Build panes in this tab
		if #panes > 1 then
			projectifier.build_panes(window, pane, panes, tab_dir)
		elseif #panes == 1 and panes[1].command then
			-- Execute command in single pane
			window:perform_action(
				wezterm.action.SendString(panes[1].command .. "\n"),
				pane
			)
		end
	end

	-- Focus first tab
	window:perform_action(wezterm.action.ActivateTab(0), pane)

	wezterm.log_info("Workspace built: " .. workspace_name)
end

-- Build panes within a tab
function projectifier.build_panes(window, pane, panes_config, base_dir)
	local focus_pane_id = nil

	for pane_index, pane_config in ipairs(panes_config) do
		local pane_dir = pane_config.dir and (base_dir .. "/" .. pane_config.dir) or base_dir
		local command = pane_config.command
		local split = pane_config.split or (pane_index > 1 and "right" or nil)

		-- Create pane (skip first one as it already exists)
		if pane_index > 1 then
			local split_action = split == "bottom" and
				wezterm.action.SplitVertical({ domain = "CurrentPaneDomain", cwd = pane_dir }) or
				wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain", cwd = pane_dir })

			window:perform_action(split_action, pane)
			wezterm.sleep_ms(50)
		end

		-- Execute command if specified
		if command then
			-- Change directory and run command
			local full_command = "cd '" .. pane_dir .. "' && " .. command .. "\n"
			window:perform_action(wezterm.action.SendString(full_command), pane)
		end

		-- Track focus pane
		if pane_config.focus then
			focus_pane_id = pane_index
		end
	end

	-- Set focus if specified
	if focus_pane_id and focus_pane_id > 1 then
		-- Navigate to the focused pane (simplified - would need pane ID tracking for complex layouts)
		for i = 2, focus_pane_id do
			window:perform_action(wezterm.action.ActivatePaneDirection("Next"), pane)
			wezterm.sleep_ms(25)
		end
	end
end

-- Create project picker interface
function projectifier.show_project_picker(window, pane)
	local projects = projectifier.discover_projects()

	if #projects == 0 then
		window:toast_notification("WezTerm", "No project configurations found in " .. projectifier.projects_dir, nil,
			3000)
		return
	end

	-- Create a temporary script that will handle project selection and building
	local temp_script = "/tmp/wezterm_projectifier.sh"
	local script_content = [[#!/bin/bash
		
		echo "Found ]] .. #projects .. [[ project configurations..."
		echo "Opening project selector..."
		
		# Create project list with metadata
		cat > /tmp/projects.txt << 'EOF'
]]

	-- Add projects to script
	for i, project in ipairs(projects) do
		local display = project.display_name
		if project.root_dir and project.root_dir ~= wezterm.home_dir then
			display = display .. " (" .. project.root_dir .. ")"
		end
		script_content = script_content .. display .. "\n"
	end

	script_content = script_content .. [[EOF
		
		# Use fzf to select project
		selected=$(cat /tmp/projects.txt | /opt/homebrew/bin/fzf \
			--prompt='Select project: ' \
			--height=40% \
			--reverse \
			--preview='echo "Project: {}"')
		
		if [ -n "$selected" ]; then
			echo "Selected project: $selected"
			echo "Building workspace..."
			
			# Write selection to temp file for WezTerm to read
			echo "$selected" > /tmp/selected_project.txt
			
			echo "Project selection saved. WezTerm will build the workspace."
			sleep 1
		else
			echo "No project selected"
			rm -f /tmp/selected_project.txt
			sleep 1
		fi
		
		# Cleanup
		rm -f /tmp/projects.txt
	]]

	-- Write script to temp file
	local file = io.open(temp_script, "w")
	if file then
		file:write(script_content)
		file:close()

		-- Make script executable
		os.execute("chmod +x " .. temp_script)

		-- Spawn the script in a new tab
		window:perform_action(
			wezterm.action.SpawnCommandInNewTab({
				args = { "bash", temp_script },
			}),
			pane
		)

		-- Set up a timer to check for selection
		wezterm.time.call_after(2, function()
			projectifier.check_for_selection(window, pane, projects, 0)
		end)
	else
		window:toast_notification("WezTerm", "Could not create temporary script", nil, 3000)
	end
end

-- Check for project selection and build workspace
function projectifier.check_for_selection(window, pane, projects, attempts)
	local max_attempts = 30 -- Check for 30 seconds

	if attempts >= max_attempts then
		wezterm.log_info("Project selection timeout")
		return
	end

	local file = io.open("/tmp/selected_project.txt", "r")
	if file then
		local selected = file:read("*line")
		file:close()
		os.remove("/tmp/selected_project.txt")

		if selected and selected ~= "" then
			-- Find matching project
			for _, project in ipairs(projects) do
				local display = project.display_name
				if project.root_dir and project.root_dir ~= wezterm.home_dir then
					display = display .. " (" .. project.root_dir .. ")"
				end

				if display == selected then
					projectifier.build_workspace(window, pane, project)
					return
				end
			end

			window:toast_notification("WezTerm", "Project not found: " .. selected, nil, 3000)
		end
	else
		-- Continue checking
		wezterm.time.call_after(1, function()
			projectifier.check_for_selection(window, pane, projects, attempts + 1)
		end)
	end
end

return projectifier
