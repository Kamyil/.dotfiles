-- SPDX-License-Identifier: MIT
-- Copyright © 2024 Thiago Alves

---@diagnostic disable:assign-type-mismatch
---@type Wezterm
local wezterm = require 'wezterm'

---@class StatusBarConfigKeyTable
---@field label string?
---@field icon string?
---@field color string?

---@class StatusBarIconLibraryBattery
---@field charging string[]
---@field discharging string[]

---@class StatusBarIconLibraryMode
---@field command string
---@field workspace string
---@field search string
---@field copy string

---@class StatusBarIconLibraryPaneHost
---@field ssh string

---@class StatusBarIconLibraryTabs
---@field dir string
---@field home string
---@field process string
---@field tab string

---@class StatusBarIconLibraryTime
---@field calendar string

---@class StatusBarIconLibraryWifi
---@field active string
---@field inactive string

---@class StatusBarIconLibrary
---@field battery StatusBarIconLibraryBattery
---@field mode StatusBarIconLibraryMode
---@field pane_host StatusBarIconLibraryPaneHost
---@field tabs StatusBarIconLibraryTabs
---@field time StatusBarIconLibraryTime
---@field wifi StatusBarIconLibraryWifi

---@class StatusBarTabsConfig
---@field hide_on_single_tab boolean
---@field max_width number
---@field truncation_point number

---@class StatusBarConfig
---@field key_tables table<string, StatusBarConfigKeyTable>
---@field icons StatusBarIconLibrary
---@field tabs StatusBarTabsConfig
local M = {
  tabs = {
    hide_on_single_tab = false,
    max_width = 40,
    truncation_point = 0.4,
  }
}

M.icons = {
  battery = {
    charging = {
      wezterm.nerdfonts.md_battery_charging_outline, -- 󰢟 > 0
      wezterm.nerdfonts.md_battery_charging_low, -- 󱊤 > 5
      wezterm.nerdfonts.md_battery_charging_medium, -- 󱊥 > 40%
      wezterm.nerdfonts.md_battery_charging_high, -- 󱊦 > 90%
    },
    discharging = {
      wezterm.nerdfonts.md_battery_outline, -- 󰂎
      wezterm.nerdfonts.md_battery_low, -- 󱊡 > 5
      wezterm.nerdfonts.md_battery_medium, -- 󱊢 > 40%
      wezterm.nerdfonts.md_battery_high, -- 󱊣 > 90%
    },
  },
  mode = {
    command = wezterm.nerdfonts.md_apple_keyboard_command, -- 󰘳
    workspace = wezterm.nerdfonts.md_collage, -- 󰙀
    search = wezterm.nerdfonts.fa_search, -- 
    copy = wezterm.nerdfonts.md_content_copy, -- 󰆏
  },
  pane_host = {
    ssh = wezterm.nerdfonts.md_remote_desktop, -- 󰢹
  },
  tabs = {
    dir = wezterm.nerdfonts.md_folder_open, -- 󰝰
    home = wezterm.nerdfonts.md_home, -- 󰋜
    process = wezterm.nerdfonts.md_run, -- 󰜎
    tab = wezterm.nerdfonts.md_tab, -- 󰓩
  },
  time = {
    calendar = wezterm.nerdfonts.md_calendar_clock, -- 󰃰 date and time
  },
  wifi = {
    active = wezterm.nerdfonts.md_wifi, -- 󰖩 on
    inactive = wezterm.nerdfonts.md_wifi_strength_off_outline, -- 󰤮 off
  },
}

M.key_tables = {
  command = {
    label = 'Command',
    icon = M.icons.mode.command,
  },
  workspace = {
    icon = M.icons.mode.workspace,
  },
  search_mode = {
    label = 'Search',
    icon = M.icons.mode.search,
  },
  copy_mode = {
    label = 'Copy',
    icon = M.icons.mode.copy,
  },
}

local function merge_tables(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == 'table') and (type(t1[k] or false) == 'table') then
      merge_tables(t1[k], t2[k])
    else
      t1[k] = v
    end
  end
  return t1
end

---@param other StatusBarConfig
function M.update(other)
  return merge_tables(M, other)
end

return M
