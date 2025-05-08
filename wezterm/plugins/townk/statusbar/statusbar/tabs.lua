-- SPDX-License-Identifier: MIT
-- Copyright © 2024 Thiago Alves

---@diagnostic disable:assign-type-mismatch
---@type Wezterm
local wezterm = require 'wezterm'
local utils = require 'statusbar.utils'
local cache = require 'statusbar.cache'

---@class StatusBarTab
---@field status_config StatusBarConfig
local M = {}
M.icons = {
  ['C:\\WINDOWS\\system32\\cmd.exe'] = wezterm.nerdfonts.md_console_line,
  ['Topgrade'] = wezterm.nerdfonts.md_rocket_launch,
  ['bash'] = wezterm.nerdfonts.cod_terminal_bash,
  ['btm'] = wezterm.nerdfonts.mdi_chart_donut_variant,
  ['cargo'] = wezterm.nerdfonts.dev_rust,
  ['curl'] = wezterm.nerdfonts.mdi_flattr,
  ['docker'] = wezterm.nerdfonts.linux_docker,
  ['docker-compose'] = wezterm.nerdfonts.linux_docker,
  ['fish'] = wezterm.nerdfonts.md_fish,
  ['gh'] = wezterm.nerdfonts.dev_github_badge,
  ['git'] = wezterm.nerdfonts.dev_git,
  ['go'] = wezterm.nerdfonts.seti_go,
  ['htop'] = wezterm.nerdfonts.md_chart_areaspline,
  ['btop'] = wezterm.nerdfonts.md_chart_areaspline,
  ['kubectl'] = wezterm.nerdfonts.linux_docker,
  ['kuberlr'] = wezterm.nerdfonts.linux_docker,
  ['lazydocker'] = wezterm.nerdfonts.linux_docker,
  ['lua'] = wezterm.nerdfonts.seti_lua,
  ['make'] = wezterm.nerdfonts.seti_makefile,
  ['node'] = wezterm.nerdfonts.mdi_hexagon,
  ['nvim'] = wezterm.nerdfonts.custom_vim,
  ['pacman'] = '󰮯 ',
  ['paru'] = '󰮯 ',
  ['psql'] = wezterm.nerdfonts.dev_postgresql,
  ['pwsh.exe'] = wezterm.nerdfonts.md_console,
  ['ruby'] = wezterm.nerdfonts.cod_ruby,
  ['sudo'] = wezterm.nerdfonts.fa_hashtag,
  ['vim'] = wezterm.nerdfonts.dev_vim,
  ['wget'] = wezterm.nerdfonts.mdi_arrow_down_box,
  ['zsh'] = wezterm.nerdfonts.dev_terminal,
  ['lazygit'] = wezterm.nerdfonts.cod_github,
  ['Debug'] = wezterm.nerdfonts.cod_debug,
  ['brew'] = wezterm.nerdfonts.md_beer_outline,
}

---@param tab any
---@return string?
function M.create_tab_title(tab, max_width)
  local title
  -- local max_length = M.status_config.tabs.max_width - 5
  local max_length = max_width - 2
  local pane_info = utils.parse_pane_title(tab.active_pane.title)
  local user_title = cache.tab_name(tab.tab_id)
    or cache.pane_name(tab.active_pane.pane_id)
    or tab.tab_title

  if user_title and user_title ~= '' then
    title = M.status_config.icons.tabs.tab .. ' ' .. user_title
  else
    title = utils.basename(tab.active_pane.foreground_process_name)
    if title == '' then
      local dir = pane_info.cwd
      if dir:sub(1, 1) == '~' then
        dir = wezterm.home_dir .. dir:sub(2)
      end

      if pane_info.host then
        dir = utils.basename(utils.resolve_home_dir(dir))
        title = M.status_config.icons.pane_host.ssh .. ' ' .. dir
      else
        local dir_read = utils.is_dir(dir)
        if dir_read then
          dir = utils.basename(utils.resolve_home_dir(dir))
          if dir == '~' then
            title = M.status_config.icons.tabs.home .. ' ' .. dir
          else
            title = M.status_config.icons.tabs.dir .. ' ' .. dir
          end
        else
          local proc_name = pane_info.cwd:match '^%s*(%S+)%s*.*$'
          title = (M.icons[proc_name] or M.status_config.icons.tabs.process) .. ' ' .. dir
        end
      end
    else
      title = (M.icons[pane_info.cwd] or M.status_config.icons.tabs.process) .. ' ' .. title
    end
  end

  local extra_icons = ''
  for _, pane in ipairs(tab.panes) do
    if pane.is_zoomed then
      extra_icons = ' '
      break
    end
  end
  if pane_info.mode then
    local mode_config = M.status_config.key_tables[pane_info.mode]
    if mode_config.icon then
      extra_icons = extra_icons .. mode_config.icon
    end
  end

  if extra_icons ~= '' then
    extra_icons = ' | ' .. extra_icons
    max_length = max_length - wezterm.column_width(extra_icons)
  else
    extra_icons = ''
  end

  return (tab.tab_index + 1)
    .. ' '
    .. utils.truncated_text(title, max_length, M.status_config.tabs.truncation_point)
    .. extra_icons
end

function M.format_tab_title(tab, _, _, cfg, hover, max_width)
  local active_key_table = cache.current_key_table()
  if active_key_table and not tab.is_active then
    return ''
  end
  local title = M.create_tab_title(tab, max_width)
  if title then
    local solid_right_arrow = utf8.char(0x258c)
    local edge_background = cfg.colors.tab_bar.background
    local background = cfg.colors.tab_bar.inactive_tab.bg_color
    local foreground = cfg.colors.tab_bar.inactive_tab.fg_color
    if tab.is_active then
      background = cfg.colors.tab_bar.active_tab.bg_color
      foreground = cfg.colors.tab_bar.active_tab.fg_color
    elseif hover then
      background = cfg.colors.tab_bar.inactive_tab_hover.bg_color
      foreground = cfg.colors.tab_bar.inactive_tab_hover.fg_color
    end
    if active_key_table then
      solid_right_arrow = wezterm.nerdfonts.ple_right_half_circle_thick -- 
      local active_table = M.status_config.key_tables[active_key_table]
      if active_table then
        background = wezterm.color.parse(active_table.color)
        local fg = background:darken(0.8)
        if background:contrast_ratio(fg) < 3.8 then
          fg = background:lighten(0.6)
        end
      end
    end
    local edge_foreground = background

    return {
      { Attribute = { Intensity = 'Bold' } },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = ' ' .. title .. ' ' },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = solid_right_arrow },
      { Attribute = { Intensity = 'Normal' } },
    }
  end
end

return M
