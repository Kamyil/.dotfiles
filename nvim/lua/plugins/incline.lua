-- Floating status line (a.k.a those filenames in top right corner)
return {
  'b0o/incline.nvim',
  config = function()
    require('incline').setup({
      window = {
        placement = {
          vertical = 'bottom',
          horizontal = 'center',
        },
        padding = 0,
        margin = { vertical = 2, horizontal = 2 },
      },
      hide = {
        cursorline = true,
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
        if filename == '' then
          filename = '[No Name]'
        end
        local filetype_icon, filetype_color = require('nvim-web-devicons').get_icon_color(filename)

        local function get_git_diff()
          local icons = { removed = ' ', changed = ' ', added = ' ' }
          local signs = vim.b[props.buf].gitsigns_status_dict
          local labels = {}
          if signs == nil then
            return labels
          end
          for name, icon in pairs(icons) do
            if tonumber(signs[name]) and signs[name] > 0 then
              table.insert(labels, { icon .. signs[name] .. ' ', group = 'Diff' .. name })
            end
          end
          if #labels > 0 then
            table.insert(labels, { '| ' })
          end
          return labels
        end

        local function get_diagnostic_label()
          local icons = { error = ' ', warn = ' ', info = ' ', hint = ' ' }
          local label = {}

          for severity, icon in pairs(icons) do
            local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
            if n > 0 then
              table.insert(label, { icon .. n .. ' ', group = 'DiagnosticSign' .. severity })
            end
          end
          if #label > 0 then
            table.insert(label, { '| ' })
          end
          return label
        end

        local function get_harpoon_items()
          local harpoon = require('harpoon')
          local marks = harpoon:list().items
          local current_file_path = vim.fn.expand('%:p:.')
          local label = {}

          for id, item in ipairs(marks) do
            if item.value == current_file_path then
              table.insert(label, { id .. ' ', guifg = '#C4B38A', gui = 'bold' })
            else
              table.insert(label, { id .. ' ', guifg = '#434852' })
            end
          end

          if #label > 0 then
            table.insert(label, 1, { '󰛢 ', guifg = '#C4B38A' })
            -- table.insert(label, 1, { ' ', guifg = '#C4B38A' })
            table.insert(label, { '| ' })
          end
          return label
        end

        local function get_file_name()
          local label = {}
          table.insert(label, { (filetype_icon or '') .. ' ', guifg = filetype_color, guibg = 'none' })
          table.insert(label, { vim.bo[props.buf].modified and ' ' or '', guifg = '#d19a66' })
          table.insert(label, { filename, gui = vim.bo[props.buf].modified and 'bold,italic' or 'bold', guifg = '#C4B38A' })

          if not props.focused then
            label['group'] = 'BufferInactive'
          end

          return label
        end

        return {
          { ' ', guifg = '#201F27', guibg = '#201F27' },
          {
            { get_harpoon_items() },
            { ' ', guifg = '#201F27', guibg = '#201F27' },
            { get_file_name() },
            { ' ', guifg = '#201F27', guibg = '#201F27' },
            { get_diagnostic_label() },
            { ' ', guifg = '#201F27', guibg = '#201F27' },
            { get_git_diff() },
            guibg = '#201F27',
          },
          { ' ', guifg = '#201F27', guibg = '#201F27' },
        }
      end,
    })
  end,
  -- Optional: Lazy load Incline
  event = 'VeryLazy',
}
