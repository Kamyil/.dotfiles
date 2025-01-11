-- Validates Ghostty terminal config
return {
  'isak102/ghostty.nvim',
  config = function()
    require('ghostty').setup()
  end,
}
