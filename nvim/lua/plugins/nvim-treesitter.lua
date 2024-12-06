return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',

  enabled = true,
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs', -- Sets main module to use for opts
  init = function()
    -- Disable italics and other decorations
    vim.cmd([[
      highlight! Keyword gui=NONE
      highlight! Conditional gui=NONE
      highlight! Function gui=NONE
      highlight! Variable gui=NONE
      highlight! Comment gui=NONE
      highlight! typescriptConditional gui=NONE
      highlight! typescriptClassBlock gui=NONE
      highlight! typescriptBlock gui=NONE
      highlight! rustConditional gui=NONE
      highlight! zshConditional gui=NONE

      highlight! link conditional.javascript Conditional
      highlight! link conditional.typescript Conditional
      highlight! link conditional.go Conditional
      highlight! link conditional.lua Conditional
    ]])
  end,
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  opts = {
    ensure_installed = {
      'bash',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
      'typescript',
      'javascript',
      'php',
      'css',
    },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = true,

      -- Disable on bigger files
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100kb;
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))

        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },
    custom_highlight = {
      -- Override Treesitter highlights
      ['Conditional'] = { style = 'NONE' },
      ['@keyword.conditional'] = { style = 'NONE' }, -- Disable italics for conditionals
      ['@keyword'] = { style = 'NONE' }, -- Disable italics for all keywords
      ['@function'] = { style = 'NONE' }, -- Disable italics for functions
      ['@variable'] = { style = 'NONE' }, -- Disable italics for variables
      ['@comment'] = { style = 'NONE' }, -- Disable italics for comments
    },
    indent = { enable = true, disable = { 'ruby' } },
  },
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
