-- Another best plugin in the world! It gives LSP diagnostics line by line (in exact place)
--
--
--
--
-- ... but override the colors a little bit since they're not matching the overall theme
vim.api.nvim_set_hl(0, 'LspDiagnosticsUnderlineError', { sp = '#c4746e', undercurl = true })
vim.api.nvim_set_hl(0, 'LspDiagnosticsVirtualTextError', { fg = '#c4746e' })
vim.api.nvim_set_hl(0, 'LspDiagnosticsFloatingError', { fg = '#c4746e' })

vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextError', { fg = '#c4746e' })
vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextWarn', { fg = '#c0a36e' })
vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextInfo', { fg = '#7e9cd8' })
vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextHint', { fg = '#6a9589' })

vim.api.nvim_set_hl(0, 'DiagnosticError', { fg = '#c4746e' }) -- Adjust to a less saturated red
vim.api.nvim_set_hl(0, 'DiagnosticWarn', { fg = '#c0a36e' })
vim.api.nvim_set_hl(0, 'DiagnosticHint', { fg = '#6a9589' })
vim.api.nvim_set_hl(0, 'DiagnosticInfo', { fg = '#7e9cd8' })

return {
  -- INFO: used previously
  -- 'Frestein/lsp_lines.nvim',
  'Maan2003/lsp_lines.nvim',
  enabled = true,
  event = 'LspAttach',
  opts = {},
  -- init = function()
  -- end,
}
