return {
  'sho-87/kanagawa-paper.nvim',
  enabled = true,
  lazy = false,
  priority = 1000,
  opts = {},
  init = function()
    -- Load the colorscheme here.
    -- Like many other themes, this one has different styles, and you could load
    -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
    vim.cmd.colorscheme('kanagawa-paper')

    -- You can configure highlights by doing something like:
    vim.cmd.hi('Comment gui=none')

    vim.cmd('highlight TelescopeBorder guibg=none')
    vim.cmd('highlight TelescopeTitle guibg=none')
  end,
}
