-- SPDX-License-Identifier: MIT
-- Copyright © 2024 Thiago Alves

---@diagnostic disable:assign-type-mismatch
---@type Wezterm
local wezterm = require("wezterm")

local M = {}

local separator = package.config:sub(1, 1) == "\\" and "\\" or "/"
-- local plugin_dir
local plugin_name = "statusbar.wezterm"
-- for _, plugin in ipairs(wezterm.plugin.list()) do
-- 	if plugin.url:sub(-#plugin_name) == plugin_name then
-- 		plugin_dir = plugin.plugin_dir
-- 		break
-- 	end
-- end

-- package.path = package.path .. ";" .. plugin_dir .. separator .. "plugin" .. separator .. "?.lua"

local segments = require("./statusbar/segments")
-- local tabs = require("./statusbar/tabs")
-- local status_config = require("./statusbar/config")
-- local cache = require("./statusbar/cache")

---Main function to apply required configurations to the user's configuration.
---@class config Config
---@param customization StatusBarConfig?
function M.apply_to_config(config, customization)
	-- status_config = status_config.update(customization or {})
	config.tab_bar_at_bottom = true
	config.use_fancy_tab_bar = false
	-- config.hide_tab_bar_if_only_one_tab = status_config.tabs.hide_on_single_tab
	-- config.tab_max_width = status_config.tabs.max_width
	-- config.tab_and_split_indices_are_zero_based = false

	-- segments.status_config = status_config
	-- wezterm.on("update-status", segments.update_status)

	-- tabs.status_config = status_config
	-- wezterm.on("format-tab-title", tabs.format_tab_title)
end

---@type StatusBarNamingElementCache
-- M.naming_cache = cache

return M
