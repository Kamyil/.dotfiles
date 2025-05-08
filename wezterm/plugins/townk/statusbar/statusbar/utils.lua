-- SPDX-License-Identifier: MIT
-- Copyright © 2024 Thiago Alves

---@diagnostic disable:assign-type-mismatch
---@type Wezterm
local wezterm = require 'wezterm'
local cache = require 'statusbar.cache'

local M = {}

---Truncates the given `text` to the given `max_length`, allowing the called to
---define where to add the ellipsis symbol on the truncation.
---@param text string
---@param max_length number
---@param truncation_point number?
---@return string
function M.truncated_text(text, max_length, truncation_point)
  local length = #text
  if length <= max_length then
    return text
  end

  local min_multiplier = 1 / max_length
  if not truncation_point or truncation_point > (1 - min_multiplier) then
    truncation_point = 1
  elseif truncation_point < min_multiplier then
    truncation_point = 0
  end

  local ellipsis
  if truncation_point == 0 then
    ellipsis = '… '
  elseif truncation_point == 1 then
    ellipsis = ' …'
  else
    ellipsis = ' … '
  end
  local ellipsis_length = #ellipsis

  local prefix_length = math.floor((max_length - ellipsis_length) * truncation_point + 0.5)
  local suffix_length = (max_length - ellipsis_length) - prefix_length
  local left = ''
  if prefix_length > 0 then
    left = wezterm.truncate_right(text, prefix_length)
  end
  local right = ''
  if suffix_length > 0 then
    right = wezterm.truncate_left(text, suffix_length)
  end

  return left .. ellipsis .. right
end

---Given a `string` representing a _path_ returns the `basename` of the path.
---@param path string
---@return string
function M.basename(path)
  local base_path, _ = string.gsub(path, '(.*[/\\])(.*)', '%2')
  return base_path
end

---Given a `string` representing a _path_, replace the absolute path of the
---HOME directory by the `~` character.
---@param path string
---@return string
function M.resolve_home_dir(path)
  local cwd = path
  local home = os.getenv 'HOME'
  cwd = cwd:gsub('^' .. home, '~')
  if cwd == '' then
    return path
  end
  return cwd
end

---Returns trus if the given `path` is a directory in the local file system.
---@param path string
---@return boolean
function M.is_dir(path)
  local f = io.open(path, 'r')
  if f then
    local _, _, code = f:read(1)
    f:close()
    return code == 21
  end
  return false
end

---@class StatusBarPaneHostInfo
---An object that represents the user and hostname of a remote host.
---@field username string
---@field hostname string

---@class StatusBarPaneInfo
---An object representing extra information about a Pane that can be inferred
---by the _built-in_ Pane Title.
---@field cwd string
---@field host StatusBarPaneHostInfo?
---@field mode string?

---Given a string representing a _built-in_ Pane Title, generates a
---`StatusBarPaneInfo` object as a snapshot of the active pane based on its
---title.
---@param title string?
---@return StatusBarPaneInfo?
function M.parse_pane_title(title)
  if not title or title == '' then
    return nil
  end

  ---@type StatusBarPaneHostInfo
  local host = nil
  local mode = cache.current_key_table()
  local target, dir = title:match '^([^:]+):%s*(.*)$'
  -- local _, _, target, dir = title:find("([^:]+):%s*(.*)")
  if target == 'Copy mode' then
    -- if active_key_table == 'search_mode' then
    --   mode = 'search'
    -- else
    --   mode = 'copy'
    -- end
    title = dir
    -- _, _, target, dir = title:find("([^:]+):%s*(.*)")
    target, dir = title:match '^([^:]+):%s*(.*)$'
  end
  if target and dir then
    local username, hostname = target:match '^([^@]+)@(.*)$'
    -- local _, _, username, hostname = target:find("([^@]+)@(.*)")
    if username and hostname then
      host = {
        username = username,
        hostname = hostname,
      }
    end
  else
    dir = title
  end
  return {
    cwd = dir,
    host = host,
    mode = mode,
  }
end

return M
