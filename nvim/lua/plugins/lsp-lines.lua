-- Another best plugin in the world! It gives LSP diagnostics line by line (in exact place)
--
--
--
--
return {
  dir = '~/Personal/Github/kamyil/lsp_lines.nvim',
  name = 'lsp_lines',
  -- BUG: used previously
  -- 'iErik/lsp_lines.nvim',
  -- 'm4kamran/lsp_lines.nvim',
  -- 'iMostfa/lsp_lines.nvim',
  -- 'Frestein/lsp_lines.nvim',
  enabled = true,
  event = 'LspAttach',
  opts = {},
  -- init = function()
  -- end,
}
