-- SPDX-License-Identifier: MIT
-- Copyright © 2024 Thiago Alves

---@diagnostic disable:assign-type-mismatch
---@type Wezterm
local wezterm = require 'wezterm'
local utils = require 'statusbar.utils'
local cache = require 'statusbar.cache'

---Returns a strings representing a status segment.
---@param color Color
---@param text string
---@param last_segment boolean?
---@return string
local function format_segment(color, text, last_segment)
  local fg = color:darken(0.8)
  if color:contrast_ratio(fg) < 3.8 then
    fg = color:lighten(0.6)
  end
  local suffix = ' '
  if last_segment then
    suffix = ''
  end
  return wezterm.format {
    { Background = { Color = color } },
    { Foreground = { Color = fg } },
    { Text = ' ' .. text .. suffix },
  }
end

local function segment_divider(left_color, right_color)
  return wezterm.format {
    { Background = { Color = left_color } },
    { Foreground = { Color = right_color } },
    { Text = wezterm.nerdfonts.ple_lower_right_triangle },
  }
end

---@class StatusBarSegment
---@field status_config StatusBarConfig
local M = {}

---Returns a Color object representing the given `key_table`.
---@param key_table string
---@return Color?
function M.mode_color(key_table, color_scheme)
  local active_table = M.status_config.key_tables[key_table]
  if not active_table or key_table == 'workspace' then
    return wezterm.color.parse(color_scheme.tab_bar.inactive_tab.bg_color)
  end
  return wezterm.color.parse(active_table.color)
end

---Status segment that displays the current terminal's mode.
---@param window Window
---@param key_table string
---@param color Color
---@param last_segment boolean?
---@return string
function M.mode(window, key_table, color, last_segment)
  local label
  local active_table = M.status_config.key_tables[key_table]
  local ws_name = window:active_workspace()
  if not active_table or (key_table == 'workspace' and ws_name == 'default') then
    return ''
  end
  ws_name = cache.workspace_name(ws_name) or ws_name
  if key_table == 'workspace' then
    label = ws_name
  else
    label = active_table.label or key_table
  end
  if active_table.icon then
    label = active_table.icon .. ' ' .. label
  end
  return format_segment(color, label, last_segment)
end

---@param window Window
---@param color Color
---@param last_segment boolean?
---@return string
function M.pane_host(window, color, last_segment)
  local pane_info = utils.parse_pane_title(window:active_pane():get_title())
  if not pane_info.host then
    return ''
  end
  return format_segment(
    color,
    M.status_config.icons.pane_host.ssh .. ' ' .. pane_info.host.hostname,
    last_segment
  )
end

---Display the computer's battery level with an icon and the percentual of
---energy left.
---@param color Color
---@param last_segment boolean?
---@return string
function M.battery(color, last_segment)
  local battery = wezterm.battery_info()[1]
  local percent = ''
  local icon = ''

  if battery.state == 'Full' then
    percent = '100%'
    icon = M.status_config.icons.battery.charging[4]
  else
    local percent_value = math.floor(battery.state_of_charge * 100 + 0.5)
    percent = percent_value .. '%'
    if percent_value >= 90 then
      icon = M.status_config.icons.battery[string.lower(battery.state)][4]
    elseif percent_value >= 40 then
      icon = M.status_config.icons.battery[string.lower(battery.state)][3]
    elseif percent_value > 5 then
      icon = M.status_config.icons.battery[string.lower(battery.state)][2]
    else
      icon = M.status_config.icons.battery[string.lower(battery.state)][1]
    end
  end
  return format_segment(color, percent .. ' ' .. icon, last_segment)
end

---Display the date and time.
---@param color Color
---@param last_segment boolean?
---@return string
function M.time(color, last_segment)
  return format_segment(
    color,
    M.status_config.icons.time.calendar .. ' ' .. wezterm.strftime '%a %b %-e %-l:%M%P',
    last_segment
  )
end

---Display the WiFi status with an icon.
---@param color Color
---@param last_segment boolean?
---@return string
function M.wifi(color, last_segment)
  local wifi = M.status_config.icons.wifi.inactive
  local output = io.popen "ifconfig en0 | awk '/status:/{print $2}'"
  if output then
    local line = output:read '*line'
    output:close()
    wifi = M.status_config.icons.wifi[line]
  end
  return format_segment(color, wifi .. ' ', last_segment)
end

---Construct the right side of the status bar with all of its segments.
---@param window Window
---@return string
function M.build_right_status(window)
  local status_mode = ''
  if window:leader_is_active() then
    status_mode = 'command'
  else
    status_mode = cache.current_key_table()
    if not status_mode then
      status_mode = 'workspace'
    end
  end

  local color_scheme = window:effective_config().resolved_palette
  local colors = wezterm.color.gradient(
    { colors = { M.mode_color(status_mode, color_scheme), color_scheme.tab_bar.background } },
    5
  )
  local dimen = window:get_dimensions()
  local bg1, bg2, bg3, bg4, bg
  local first_segment = 0
  bg = colors[5]
  if dimen.is_full_screen then
    bg1 = colors[1]
    bg2 = colors[2]
    bg3 = colors[3]
    bg4 = colors[4]
    first_segment = 4
  else
    bg3 = colors[1]
    bg4 = colors[2]
    first_segment = 2
  end

  local pane_host = M.pane_host(window, bg3)
  if pane_host == '' then
    bg4 = bg3
    first_segment = first_segment - 1
  end

  local status = ''
  local mode = M.mode(window, status_mode, bg4)
  if #mode > 0 and #pane_host > 0 then
    status = segment_divider(bg, colors[first_segment])
      .. mode
      .. segment_divider(colors[first_segment], colors[first_segment - 1])
      .. pane_host
  elseif #mode > 0 then
    status = segment_divider(bg, colors[first_segment]) .. mode
  elseif #pane_host > 0 then
    status = segment_divider(bg, colors[first_segment]) .. pane_host
  end

  if dimen.is_full_screen then
    if #status > 0 then
      status = status
        .. segment_divider(bg3, bg2)
        .. M.battery(bg2)
        .. M.wifi(bg2)
        .. segment_divider(bg2, bg1)
        .. M.time(bg1, true)
    else
      status = segment_divider(bg, bg2)
        .. M.battery(bg2)
        .. M.wifi(bg2)
        .. segment_divider(bg2, bg1)
        .. M.time(bg1, true)
    end
  end
  return status
end

---This function should be passed to the `update-status` hook of Wezterm so it
---can display an updated status bar.
---@param window Window
---@param _ Pane
function M.update_status(window, _)
  cache.store_current_key_table(window:active_key_table())
  window:set_left_status ''
  window:set_right_status(M.build_right_status(window))
end

return M
