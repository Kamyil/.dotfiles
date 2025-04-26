-- return {
--   'sainnhe/everforest',
--   enabled = true,
--   init = function()
--     -- Load the colorscheme here.
--     -- Like many other themes, this one has different styles, and you could load
--     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
--     vim.cmd.colorscheme('everforest')
--
--     -- You can configure highlights by doing something like:
--     -- vim.cmd.hi('Comment gui=none')
--
--     -- vim.cmd('highlight TelescopeBorder guibg=none')
--     -- vim.cmd('highlight TelescopeTitle guibg=none')
--   end,
-- }
--
return {
  'neanias/everforest-nvim',
  enabled = true,
  version = false,
  lazy = false,
  priority = 1000, -- make sure to load this before all the other start plugins
  init = function()
    -- Load the colorscheme here.
    -- Like many other themes, this one has different styles, and you could load
    -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
    -- vim.cmd.colorscheme('everforest')

    -- You can configure highlights by doing something like:
    -- vim.cmd.hi('Comment gui=none')

    -- vim.cmd('highlight TelescopeBorder guibg=none')
    -- vim.cmd('highlight TelescopeTitle guibg=none')
    return {
      on_highlights = function(hl, palette)
        hl.DiagnosticError = { fg = palette.none, bg = palette.none, sp = palette.red }
        hl.DiagnosticWarn = { fg = palette.none, bg = palette.none, sp = palette.yellow }
        hl.DiagnosticInfo = { fg = palette.none, bg = palette.none, sp = palette.blue }
        hl.DiagnosticHint = { fg = palette.none, bg = palette.none, sp = palette.green }
        -- The default highlights for TSBoolean is linked to `Purple` which is fg
        -- purple and bg none. If we want to just add a bold style to the existing,
        -- we need to have the existing *and* the bold style. (We could link to
        -- `PurpleBold` here otherwise.)
        hl.TSBoolean = { fg = palette.purple, bg = palette.none, bold = true }
      end,
    }
  end,
}
