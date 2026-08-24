vim.cmd('highlight clear')
vim.o.termguicolors = true
vim.g.colors_name = 'koyanagi'

local colors = {
  bg = '#1c1c1e',
  surface = '#2c2c2e',
  selection = '#808080',
  fg = '#f2f2f2',
  muted = '#6a6a6a',
  border = '#7a7a7a',
  accent = '#ffdd80',
  danger = '#e65c5c',
  success = '#80e680',
}

local set = vim.api.nvim_set_hl
local groups = {
  Normal = { fg = colors.fg, bg = colors.bg },
  NormalFloat = { fg = colors.fg, bg = colors.surface },
  FloatBorder = { fg = colors.border, bg = colors.surface },
  Comment = { fg = colors.muted, italic = true },
  Constant = { fg = colors.accent },
  String = { fg = colors.muted },
  Number = { fg = colors.accent },
  Boolean = { fg = colors.border, bold = true },
  Identifier = { fg = colors.fg },
  Function = { fg = colors.border, bold = true },
  Statement = { fg = colors.accent, bold = true },
  Keyword = { fg = colors.border, bold = true },
  Operator = { fg = colors.border },
  Type = { fg = colors.accent, italic = true },
  Special = { fg = colors.accent },
  Directory = { fg = colors.border },
  CursorLine = { bg = colors.surface },
  CursorLineNr = { fg = colors.accent, bold = true },
  LineNr = { fg = colors.muted },
  SignColumn = { bg = colors.bg },
  Visual = { bg = colors.selection },
  Search = { fg = colors.bg, bg = colors.fg },
  IncSearch = { fg = colors.bg, bg = colors.accent },
  Pmenu = { fg = colors.fg, bg = colors.surface },
  PmenuSel = { fg = colors.bg, bg = colors.accent },
  StatusLine = { fg = colors.fg, bg = colors.surface },
  StatusLineNC = { fg = colors.muted, bg = colors.surface },
  WinSeparator = { fg = colors.border },
  ErrorMsg = { fg = colors.danger },
  WarningMsg = { fg = colors.accent },
  DiffAdd = { bg = '#1e2e28' },
  DiffChange = { bg = '#2a2435' },
  DiffDelete = { bg = '#2e1e24' },
  DiagnosticError = { fg = colors.danger },
  DiagnosticWarn = { fg = colors.accent },
  DiagnosticInfo = { fg = colors.border },
  DiagnosticHint = { fg = colors.muted },
}

for group, opts in pairs(groups) do
  set(0, group, opts)
end
