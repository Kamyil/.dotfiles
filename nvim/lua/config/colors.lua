vim.cmd(':hi statusline guibg=NONE')
require('config.plugin_setup').apply_terminal_theme_highlights()

-- Set the colorscheme selected by ~/.dotfiles/scripts/theme.
local active_theme = require('config.theme')
active_theme.apply()
vim.cmd(':hi statusline guibg=NONE')

-- Keep every Neovim highlight upright, including groups added by plugins.
local function disable_italics()
  for name, highlight in pairs(vim.api.nvim_get_hl(0, {})) do
    if highlight.italic then
      highlight.italic = false
      vim.api.nvim_set_hl(0, name, highlight)
    end
  end

  -- Svelte marks local readonly functions with this higher-priority semantic
  -- token. Keep its color without switching font faces during token refreshes.
  local readonly_function = vim.api.nvim_get_hl(0, {
    name = '@lsp.typemod.function.readonly',
    link = false,
  })
  readonly_function.bold = false
  readonly_function.italic = false
  readonly_function.cterm = nil
  vim.api.nvim_set_hl(0, '@lsp.typemod.function.readonly', readonly_function)
end

disable_italics()

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = disable_italics,
})

-- =============================================================================
-- MARKDOWN HEADING HIGHLIGHTS (render-markdown.nvim)
-- =============================================================================
-- These highlight groups give headings visual hierarchy through backgrounds,
-- underlines, and bold styling — compensating for the terminal's lack of
-- per-cell font sizes (Kitty's text sizing protocol can't be used inline by
-- Neovim's TUI). The :MarkdownPreview command (below) uses Kitty's OSC 66
-- protocol to actually render headings at larger font sizes.

-- Heading foregrounds: bold + bright per level
local palette = active_theme.palette
vim.api.nvim_set_hl(0, 'RenderMarkdownH1', { fg = palette.foreground, bold = true })
vim.api.nvim_set_hl(0, 'RenderMarkdownH2', { fg = palette.foreground, bold = true })
vim.api.nvim_set_hl(0, 'RenderMarkdownH3', { fg = palette.yellow, bold = true })
vim.api.nvim_set_hl(0, 'RenderMarkdownH4', { fg = palette.yellow, bold = false })
vim.api.nvim_set_hl(0, 'RenderMarkdownH5', { fg = palette.muted, bold = false })
vim.api.nvim_set_hl(0, 'RenderMarkdownH6', { fg = palette.muted, bold = false })

-- Heading backgrounds: subtle tint, strongest for h1-h2
vim.api.nvim_set_hl(0, 'RenderMarkdownH1Bg', { bg = palette.selection })
vim.api.nvim_set_hl(0, 'RenderMarkdownH2Bg', { bg = palette.selection })
vim.api.nvim_set_hl(0, 'RenderMarkdownH3Bg', { bg = palette.background })
vim.api.nvim_set_hl(0, 'RenderMarkdownH4Bg', { bg = palette.background })
vim.api.nvim_set_hl(0, 'RenderMarkdownH5Bg', { bg = palette.background })
vim.api.nvim_set_hl(0, 'RenderMarkdownH6Bg', { bg = palette.background })
