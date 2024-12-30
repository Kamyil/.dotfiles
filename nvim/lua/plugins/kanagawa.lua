return {
  'rebelot/kanagawa.nvim',
  enabled = false,
  init = function()
    -- Load the colorscheme here.
    -- Like many other themes, this one has different styles, and you could load
    -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
    vim.cmd.colorscheme('kanagawa-dragon')

    -- You can configure highlights by doing something like:
    vim.cmd.hi('Comment gui=none')

    vim.cmd('highlight TelescopeBorder guibg=none')
    vim.cmd('highlight TelescopeTitle guibg=none')
  end,
  setup = {
    transparent = true, -- do not set background color
    theme = 'wave', -- Load "wave" theme when 'background' option is not set
    undercurl = true, -- enable undercurls
    commentStyle = { italic = false },
    functionStyle = {},
    keywordStyle = { italic = true },
    statementStyle = { bold = true },

    overrides = function(colors)
      local theme = colors.theme
      local makeDiagnosticColor = function(color)
        local c = require('kanagawa.lib.color')
        return { fg = color, bg = c(color):blend(theme.ui.bg, 0.95):to_hex() }
      end

      return {
        -- Completion (cmp)
        Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
        PmenuSel = { fg = 'NONE', bg = theme.ui.bg_p2 },
        -- PmenuSbar = { bg = theme.ui.bg_m1 },
        -- Blink highlights
        BlinkCmpMenu = { fg = colors.palette.autumnYellow },
        BlinkCursorLine = { bg = colors.palette.sumiInk3 },
        BlinkCursorColumn = { bg = colors.palette.waveBlue1 },
        BlinkCursorLineInsert = { bg = colors.palette.autumnYellow },
        BlinkCursorLineVisual = { bg = colors.palette.springBlue },
        BlinkCursorLineReplace = { bg = colors.palette.samuraiRed },
        BlinkCursorColumnInsert = { bg = colors.palette.autumnYellow },
        BlinkCursorColumnVisual = { bg = colors.palette.springBlue },
        BlinkCursorColumnReplace = { bg = colors.palette.samuraiRed },
        -- Telescope
        TelescopeTitle = { fg = theme.ui.special, bold = true },
        TelescopePromptNormal = { bg = theme.ui.bg_p1 },
        TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
        TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
        TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
        TelescopePreviewNormal = { bg = theme.ui.bg_dim },
        TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
        PmenuThumb = { bg = theme.ui.bg_p2 },
        --
        -- -- Diagnostics
        DiagnosticVirtualTextHint = makeDiagnosticColor(theme.diag.hint),
        DiagnosticVirtualTextInfo = makeDiagnosticColor(theme.diag.info),
        DiagnosticVirtualTextWarn = makeDiagnosticColor(theme.diag.warning),
        DiagnosticVirtualTextError = makeDiagnosticColor(theme.diag.error),
      }
    end,
  },
}
