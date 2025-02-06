local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local conf = require('telescope.config').values

local M = {}

--- Allows running live grep with the ability to filter the contents via extensions
--- @usage: type some words and then type pipe followed by star with extension name to filter it
--- @example `some word | *.ts`
M.live_multigrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.loop.cwd()

  local finder = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt:match('^%s*$') then
        return nil
      end

      local pieces = vim.split(prompt, '%s*|%s*') -- Splits on '|' with optional surrounding spaces
      local args = { 'rg' }

      if pieces[1] and pieces[1] ~= '' then
        table.insert(args, '-e')
        table.insert(args, pieces[1])
      end

      if pieces[2] and pieces[2] ~= '' then
        table.insert(args, '-g')
        table.insert(args, pieces[2])
      end

      -- Append any additional args from opts
      if opts.additional_args then
        for _, arg in ipairs(opts.additional_args) do
          table.insert(args, arg)
        end
      end

      -- Common rg flags
      table.insert(args, '--color=never')
      table.insert(args, '--no-heading')
      table.insert(args, '--with-filename')
      table.insert(args, '--line-number')
      table.insert(args, '--column')
      table.insert(args, '--smart-case')

      return args
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers
    .new(opts, {
      debounce = 100,
      prompt_title = 'Multi Grep',
      finder = finder,
      previewer = conf.grep_previewer(opts),
      sorter = require('telescope.sorters').get_generic_fuzzy_sorter(),
    })
    :find()
end

return M
