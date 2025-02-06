-- File: lua/custom/telescope_mdn.lua

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local previewers = require('telescope.previewers')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local curl = require('plenary.curl')

local M = {}

-- Function to fetch MDN documentation
local function fetch_mdn_docs(query, callback)
  -- URL encoding for the query
  local encoded_query = vim.fn.system('python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" ' .. query)
  encoded_query = vim.trim(encoded_query)

  -- Construct the search URL
  local url = 'https://developer.mozilla.org/en-US/search.json?locale=en-US&query=' .. encoded_query .. '&include_unpublished=false'

  -- Perform HTTP GET request
  curl.get(url, {
    callback = function(response)
      if response.status ~= 200 then
        vim.schedule(function()
          vim.notify('Failed to fetch MDN docs: ' .. response.status, vim.log.levels.ERROR)
        end)
        return
      end

      local data = vim.fn.json_decode(response.body)
      callback(data)
    end,
  })
end

-- Picker for MDN Documentation
function M.mdn_docs(opts)
  opts = opts or {}

  pickers
    .new(opts, {
      prompt_title = 'MDN Documentation',
      finder = finders.new_async_function(function(prompt, process_result)
        if prompt == '' then
          process_result({})
          return
        end

        fetch_mdn_docs(prompt, function(data)
          if not data.documents then
            process_result({})
            return
          end

          local results = {}
          for _, doc in ipairs(data.documents) do
            table.insert(results, {
              title = doc.title,
              summary = doc.summary or '',
              url = doc.url,
              body = doc.body_html or '',
            })
          end
          process_result(results)
        end)
      end),
      sorter = sorters.get_generic_fuzzy_sorter(),
      previewer = previewers.new_buffer_previewer({
        define_preview = function(self, entry, status)
          local bufnr = self.state.bufnr
          vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { entry.value.summary })
          vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          vim.fn.jobstart('xdg-open ' .. selection.value.url)
        end)
        return true
      end,
    })
    :find()
end

return M
