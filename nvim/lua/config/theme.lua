local M = {}

local fallback = vim.fn.expand('~/.dotfiles/themes/kanagawa-paper/theme.json')
local active = vim.fn.expand('~/.local/state/dotfiles-theme/current/theme.json')

local function read_palette(path)
  local file = io.open(path, 'r')
  if not file then
    return nil
  end
  local contents = file:read('*a')
  file:close()
  local ok, palette = pcall(vim.json.decode, contents)
  return ok and palette or nil
end

M.palette = read_palette(active)
  or read_palette(fallback)
  or {
    name = 'kanagawa-paper',
    nvim_colorscheme = 'kanagawa-paper-ink',
    background = '#14141a',
    foreground = '#DCD7BA',
    selection = '#363646',
    muted = '#9e9b93',
    red = '#c4746e',
    green = '#699469',
    yellow = '#c4b28a',
    blue = '#809ba7',
    purple = '#a292a3',
    aqua = '#8ea49e',
  }

function M.apply()
  if M.palette.name == 'gruvbox-material-hard' then
    vim.g.gruvbox_material_background = 'hard'
    vim.g.gruvbox_material_foreground = 'material'
    vim.g.gruvbox_material_enable_italic = 0
  end
  vim.cmd.colorscheme(M.palette.nvim_colorscheme)
end

return M
