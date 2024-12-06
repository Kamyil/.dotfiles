return {
  'nvim-tree/nvim-web-devicons',
  enabled = true,
  lazy = false,
  ft = '*',
  opts = function()
    return {
      override = {
        deb = { icon = '', name = 'Deb' },
        lock = { icon = '󰌾', name = 'Lock' },
        mp3 = { icon = '󰎆', name = 'Mp3' },
        mp4 = { icon = '', name = 'Mp4' },
        out = { icon = '', name = 'Out' },
        ['robots.txt'] = { icon = '󰚩', name = 'Robots' },
        ttf = { icon = '', name = 'TrueTypeFont' },
        rpm = { icon = '', name = 'Rpm' },
        woff = { icon = '', name = 'WebOpenFontFormat' },
        woff2 = { icon = '', name = 'WebOpenFontFormat2' },
        xz = { icon = '', name = 'Xz' },
        zip = { icon = '', name = 'Zip' },
        zsh = {
          icon = '',
          color = '#428850',
          cterm_color = '65',
          name = 'Zsh',
        },
      },
      -- globally enable different highlight colors per icon (default to true)
      -- if set to false all icons will have the default icon's color
      color_icons = true,
      -- globally enable default icons (default to false)
      -- will get overriden by `get_icons` option
      default = true,
      -- globally enable "strict" selection of icons - icon will be looked up in
      -- different tables, first by filename, and if not found by extension; this
      -- prevents cases when file doesn't have any extension but still gets some icon
      -- because its name happened to match some extension (default to false)
      strict = true,
      -- set the light or dark variant manually, instead of relying on `background`
      -- (default to nil)
      variant = 'dark',
      -- same as `override` but specifically for overrides by filename
      -- takes effect when `strict` is true
      override_by_filename = {
        ['.gitignore'] = {
          icon = '',
          color = '#f1502f',
          name = 'Gitignore',
        },
      },
      -- same as `override` but specifically for overrides by extension
      -- takes effect when `strict` is true
      override_by_extension = {
        ['log'] = {
          icon = '',
          color = '#81e043',
          name = 'Log',
        },
      },
      -- same as `override` but specifically for operating system
      -- takes effect when `strict` is true
      override_by_operating_system = {
        ['apple'] = {
          icon = '',
          color = '#A2AAAD',
          cterm_color = '248',
          name = 'Apple',
        },
      },
    }
  end,
}
