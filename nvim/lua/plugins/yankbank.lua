-- For Yank (copy) history. Kinda like clipboard history but for yanks (copies)
return {
  'ptdewey/yankbank-nvim',
  enabled = true,
  dependencies = 'kkharji/sqlite.lua',
  lazy = false,
  config = function()
    require('yankbank').setup({
      persist_type = 'sqlite',
    })
  end,
}
