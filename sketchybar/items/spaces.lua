-- Aerospace workspaces matching waybar's hyprland/workspaces style
local appearance = require("appearance")
local sbar = require("sketchybar")
local icons = require("icons")

local workspace_names = {
	["1"] = "1",
	["2"] = "2",
	["3"] = "3",
	["4"] = "4",
	["5"] = "5",
	["6"] = "6",
	["7"] = "7",
	["8"] = "8",
	["9"] = "9",
	["10"] = "0",
}

local query_workspaces = "aerospace list-workspaces --all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json"

local root = sbar.add("item", { drawing = false })
local workspaces = {}

local function updateWorkspaces()
	sbar.exec(query_workspaces, function(workspaces_and_monitors)
		for _, entry in ipairs(workspaces_and_monitors) do
			local space_index = entry.workspace
			local monitor_id = math.floor(entry["monitor-appkit-nsscreen-screens-id"])
			if workspaces[space_index] then
				workspaces[space_index]:set({
					display = monitor_id,
				})
			end
		end
	end)
end

sbar.exec(query_workspaces, function(workspaces_and_monitors)
	for _, entry in ipairs(workspaces_and_monitors) do
		local workspace_index = entry.workspace
		local style = appearance.styles.workspace

		local workspace = sbar.add("item", "workspace." .. workspace_index, {
			position = "left",
			background = style.background,
			click_script = "aerospace workspace " .. workspace_index,
			icon = {
				color = style.icon.color,
				highlight_color = style.icon.highlight_color,
				font = style.icon.font,
				padding_left = style.icon.padding_left,
				padding_right = style.icon.padding_right,
				string = workspace_names[workspace_index] or workspace_index,
			},
			label = { drawing = false },
		})

		workspaces[workspace_index] = workspace

		workspace:subscribe("aerospace_workspace_change", function(env)
			local focused_workspace = env.FOCUSED_WORKSPACE
			local is_focused = focused_workspace == workspace_index

			sbar.animate("tanh", 10, function()
				workspace:set({
					icon = { 
						highlight = is_focused,
						string = is_focused and icons.workspace.active or (workspace_names[workspace_index] or workspace_index),
					},
				})
			end)
		end)
	end

	-- Initial setup
	updateWorkspaces()

	root:subscribe("display_change", function()
		updateWorkspaces()
	end)

	-- Set initial focused state
	sbar.exec("aerospace list-workspaces --focused", function(focused_workspace)
		focused_workspace = focused_workspace:match("^%s*(.-)%s*$")
		if workspaces[focused_workspace] then
			workspaces[focused_workspace]:set({
				icon = { 
					highlight = true,
					string = icons.workspace.active,
				},
			})
		end
	end)
end)
