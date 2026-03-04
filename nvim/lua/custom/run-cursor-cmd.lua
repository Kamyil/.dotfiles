local M = {}

local function get_line_command()
  local line = vim.api.nvim_get_current_line()
  local cmd = vim.trim(line)
  if cmd == '' then
    return nil
  end
  return cmd
end

local function get_visual_command()
  local lines = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'))
  local cmd = table.concat(lines, '\n')
  cmd = vim.trim(cmd)
  if cmd == '' then
    return nil
  end
  return cmd
end

local function run_in_terminal(cmd)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  vim.fn.termopen(cmd)
  vim.cmd('startinsert')
end

function M.run()
  local cmd = get_line_command()
  if not cmd then
    vim.notify('No command on current line', vim.log.levels.WARN)
    return
  end
  run_in_terminal(cmd)
end

function M.run_visual()
  local cmd = get_visual_command()
  if not cmd then
    vim.notify('No command in visual selection', vim.log.levels.WARN)
    return
  end
  run_in_terminal(cmd)
end

vim.api.nvim_create_user_command('RunCursorCmd', M.run, { desc = 'Run command under cursor in terminal' })
vim.api.nvim_create_user_command('RunVisualCmd', M.run_visual, { range = true, desc = 'Run visual selection in terminal' })

vim.keymap.set('n', '<leader>tc', M.run, { desc = 'Run command under cursor in terminal' })
vim.keymap.set('v', '<leader>tc', M.run_visual, { desc = 'Run visual selection in terminal' })

return M
