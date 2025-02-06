-- File: lua/custom/telescope_phpdocs.lua

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local previewers = require('telescope.previewers')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local Job = require('plenary.job')

local M = {}

-- Function to load PHPDocs JSON
local function load_phpdocs()
  local json_path = '/path/to/phpdocs.json' -- Replace with your actual path
  local content = vim.fn.readfile(json_path)
  local json_str = table.concat(content, '\n')
  local data = vim.fn.json_decode(json_str)
  return data
end

-- Picker for PHPDocs Documentation
function M.phpdocs_docs(opts)
  opts = opts or {}

  local phpdocs_data = load_phpdocs()
  if not phpdocs_data then
    vim.notify('Failed to load PHPDocs data.', vim.log.levels.ERROR)
    return
  end

  pickers
    .new(opts, {
      prompt_title = 'PHPDocs Documentation',
      finder = finders.new_table({
        results = phpdocs_data.functions, -- Adjust based on your JSON structure
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name,
          }
        end,
      }),
      sorter = sorters.get_generic_fuzzy_sorter(),
      previewer = previewers.new_buffer_previewer({
        define_preview = function(self, entry, status)
          local bufnr = self.state.bufnr
          vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { entry.value.description })
          vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          -- Display the URL or open in browser
          if selection.value.url then
            vim.fn.jobstart('xdg-open ' .. selection.value.url)
          else
            vim.notify('No URL available for this entry.', vim.log.levels.INFO)
          end
        end)
        return true
      end,
    })
    :find()
end

return M
