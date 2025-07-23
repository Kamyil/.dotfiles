local customFilter = {
  -- Called on every item in the current file list
  filter = function(item, filter)
    -- `filter.input` is what you typed in the prompt
    local input = filter.input or ''
    -- If the user typed something like:   myTerm | .md
    -- this pattern tries to capture "myTerm" as `term` and ".md" as `ext`.
    local term, ext = input:match('^(.-)%s*|%s*(%S+)$')
    if ext then
      -- Build a Lua pattern that matches the extension at the end
      -- e.g. ".md" -> "%.md$"
      local extPattern = ext:gsub('%.', '%%.') .. '$'

      -- If `term` is non-empty, do some basic substring matching on item.name
      if term and #term > 0 then
        if not item.name:lower():find(term:lower(), 1, true) then
          return false
        end
      end

      -- Now ensure the file path ends in that extension
      if item.path and not item.path:match(extPattern) then
        return false
      end

      -- Survived both checks => item is valid
      return true
    end

    -- If there's no "| ext" in the input, fall back to normal
    -- (i.e. don’t do any special filtering)
    return true
  end,

  -- Optional: transform function, run before `filter` is applied
  -- Return `true` if you want to “force refresh” the finder.
  -- If you only want to do in‐memory filtering, you can usually skip this
  -- or just return false.
  transform = function(picker, filter)
    -- If you want it to re-filter after every keystroke, you could do:
    -- return true
    return false
  end,
}

return {
  'folke/snacks.nvim',
  ---@type snacks.Config
  opts = {
    notifier = {
      -- your notifier configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    bigfile = {
      notify = true,
      -- your bigfile configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      -- notify = true, -- show notification when big file detected
      size = 1.0 * 1024 * 1024, -- 1.0MB
    },

    explorer = {
      -- your explorer configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      disable = false,
      replace_netrw = false, -- Replace netrw with the snacks explorer
      ui_select = true,
      diagnostics_open = true,
      git_status_open = true,
      layout = { preset = 'vscode', preview = true },
    },

    -- Simple notifier
    -- notifier = { -- INFO: Disabled due to showing 'No info available' unnecessarly while trying to trigger LSP info
    --
    -- your notifier configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    -- },

    -- Scope detection based on treesitter or indent.
    -- The indent-based algorithm is similar to what is used in mini.indentscope.
    scope = {
      -- your scope configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },

    statuscolumn = {
      -- your statuscolumn configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      left = { 'mark', 'sign' }, -- priority of signs on the left (high to low)
      right = { 'fold', 'git' }, -- priority of signs on the right (high to low)
      folds = {
        open = false, -- show open fold icons
        git_hl = false, -- use Git Signs hl for fold icons
      },
      git = {
        -- patterns to match Git signs
        patterns = { 'GitSign', 'MiniDiffSign' },
      },
      refresh = 50, -- refresh at most every 50ms
    },

    layout = {
      backdrop = false,
      width = 40,
      min_width = 40,
      height = 0,
      position = 'left',
      border = 'none',
      box = 'vertical',
      {
        win = 'input',
        height = 1,
        border = 'rounded',
        title = '{title} {live} {flags}',
        title_pos = 'center',
      },
      { win = 'list', border = 'none' },
      { win = 'preview', title = '{preview}', height = 0.4, border = 'top' },
    },

    picker = {
      ---@type "input"|"list"|false where to focus when the picker is opened (defaults to "input")
      focus = 'input',
      debug = {
        scores = false, -- show scores in the list
      },
      matcher = {
        frecency = true,
      },
      filter = customFilter,
      layout = {
        border = 'single',
      },
    },

    lazygit = {
      -- automatically configure lazygit to use the current colorscheme
      -- and integrate edit with the current neovim instance
      configure = true,
      -- extra configuration for lazygit that will be merged with the default
      -- snacks does NOT have a full yaml parser, so if you need `"test"` to appear with the quotes
      -- you need to double quote it: `"\"test\""`
      config = {
        os = { editPreset = 'nvim-remote' },
        gui = {
          -- set to an empty string "" to disable icons
          nerdFontsVersion = '3',
        },
      },
      theme_path = vim.fs.normalize(vim.fn.stdpath('cache') .. '/lazygit-theme.yml'),
      -- Theme for lazygit
      theme = {
        [241] = { fg = 'Special' },
        activeBorderColor = { fg = 'MatchParen', bold = true },
        cherryPickedCommitBgColor = { fg = 'Identifier' },
        cherryPickedCommitFgColor = { fg = 'Function' },
        defaultFgColor = { fg = 'Normal' },
        inactiveBorderColor = { fg = 'FloatBorder' },
        optionsTextColor = { fg = 'Function' },
        searchingActiveBorderColor = { fg = 'MatchParen', bold = true },
        selectedLineBgColor = { bg = 'Visual' }, -- set to `default` to have no background colour
        unstagedChangesColor = { fg = 'DiagnosticError' },
      },
      win = {
        style = 'lazygit',
      },
    },
  },
}
