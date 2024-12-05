-- Another best plugin in the world! It gives LSP diagnostics line by line (in exact place)
return {

  enabled = true,
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  event = 'LspAttach',
  opts = {},
}
