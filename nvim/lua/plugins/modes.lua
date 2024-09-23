-- Best plugin in the world. It highlights current Vim mode in the cursor giving you immidietate feedback on which mode you're in <3
return {
  { 'folke/which-key.nvim', optional = true, opts = { plugins = { presets = { operators = false } } } },
  {
    'mvllow/modes.nvim',
    version = '^0.2',
    event = 'VeryLazy',
    opts = {},
  },
}
