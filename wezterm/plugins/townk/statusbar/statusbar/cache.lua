-- SPDX-License-Identifier: MIT
-- Copyright © 2024 Thiago Alves

---@diagnostic disable:assign-type-mismatch
---@type Wezterm
local wezterm = require 'wezterm'

---@class StatusBarNamingElementCache
---@field store_workspace_name fun(workspace_id: string, title: string)
---@field store_tab_name fun(id: number, title: string)
---@field store_pane_name fun(id: number, title: string)
---@field store_current_key_table fun(key_table: string)
---@field workspace_name fun(workspace_id: string): string?
---@field tab_name fun(id: number): string?
---@field pane_name fun(id: number): string?
---@field current_key_table fun(): string?
local M = {}

local function set_cache(cached)
  wezterm.GLOBAL.sb_plugin = cached
end

local function get_cached()
  if not wezterm.GLOBAL.sb_plugin then
    set_cache { _workspaces = {}, _tabs = {}, _panes = {} }
  end
  return wezterm.GLOBAL.sb_plugin
end

---@param workspace_id string
---@param name string
function M.store_workspace_name(workspace_id, name)
  local cached = get_cached()
  cached._workspaces[workspace_id] = name
  set_cache(cached)
end

---@param tab_id number
---@param name string
function M.store_tab_name(tab_id, name)
  local cached = get_cached()
  cached._tabs[wezterm.to_string(tab_id)] = name
  set_cache(cached)
end

---@param pane_id number
---@param name string
function M.store_pane_name(pane_id, name)
  local cached = get_cached()
  cached._panes[wezterm.to_string(pane_id)] = name
  set_cache(cached)
end

---@param key_table string
function M.store_current_key_table(key_table)
  local cached = get_cached()
  cached._key_table = key_table
  set_cache(cached)
end

---@param workspace_id string
---@return string?
function M.workspace_name(workspace_id)
  return get_cached()._workspaces[workspace_id]
end

---@param tab_id number
---@return string?
function M.tab_name(tab_id)
  return get_cached()._tabs[wezterm.to_string(tab_id)]
end

---@param pane_id number
---@return string?
function M.pane_name(pane_id)
  return get_cached()._panes[wezterm.to_string(pane_id)]
end

---@return string?
function M.current_key_table()
  return get_cached()._key_table
end

return M
