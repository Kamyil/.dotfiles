-- for having color picker + highlighted colors
return {
  'uga-rosa/ccc.nvim',
  enabled = true,
  config = function()
    local ccc = require('ccc')
    local mapping = ccc.mapping

    ccc.setup({
      -- Your preferred settings
      -- Example: enable highlighter
      highlighter = {
        auto_enable = true,
        lsp = true,
      },
    })
  end,
}
