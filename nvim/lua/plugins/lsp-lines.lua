-- Another best plugin in the world! It gives LSP diagnostics line by line (in exact place)
return {
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  event = "LspAttach",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>uD"] = { function() require("lsp_lines").toggle() end, desc = "Toggle lsp-lines (better located messages)" },
          },
        },

        diagnostics = {
          virtual_text = false,
        },
      },
    },
  },
  opts = {},
}
