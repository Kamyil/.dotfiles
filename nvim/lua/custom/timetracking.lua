local M = {}

local state = {
  start_time = nil,
  start_display = nil,
  timer = nil,
  elapsed_seconds = 0,
}

local function format_duration(seconds)
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60

  if hours > 0 then
    return string.format('%dh %02dm', hours, minutes)
  elseif minutes > 0 then
    return string.format('%dm %02ds', minutes, secs)
  else
    return string.format('%ds', secs)
  end
end

local function format_elapsed_display(seconds)
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60
  return string.format('%02d:%02d:%02d', hours, minutes, secs)
end

function M.start()
  if state.start_time then
    vim.notify('Timer already running! Use <leader>nte to stop it first.', vim.log.levels.WARN)
    return
  end

  state.start_time = os.time()
  state.start_display = os.date('%H:%M')
  state.elapsed_seconds = 0

  state.timer = vim.loop.new_timer()
  state.timer:start(1000, 1000, vim.schedule_wrap(function()
    state.elapsed_seconds = os.difftime(os.time(), state.start_time)
    vim.cmd('redrawstatus')
  end))

  vim.notify('⏱️ Timer started at ' .. state.start_display, vim.log.levels.INFO)
end

function M.stop()
  if not state.start_time then
    vim.notify('No timer running! Use <leader>nts to start one.', vim.log.levels.WARN)
    return
  end

  local end_time = os.time()
  local end_display = os.date('%H:%M')
  local duration_seconds = os.difftime(end_time, state.start_time)
  local duration_formatted = format_duration(duration_seconds)

  if state.timer then
    state.timer:stop()
    state.timer:close()
    state.timer = nil
  end

  local output = string.format('@time-spent(%s - %s, %s)', state.start_display, end_display, duration_formatted)

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local new_line = line:sub(1, col + 1) .. output .. line:sub(col + 2)
  vim.api.nvim_set_current_line(new_line)
  vim.api.nvim_win_set_cursor(0, { row, col + #output })

  vim.notify('⏱️ Timer stopped: ' .. duration_formatted, vim.log.levels.INFO)

  state.start_time = nil
  state.start_display = nil
  state.elapsed_seconds = 0
end

function M.statusline()
  if not state.start_time then
    return ''
  end
  return '⏱️ ' .. format_elapsed_display(state.elapsed_seconds)
end

function M.is_running()
  return state.start_time ~= nil
end

function M.toggle()
  if state.start_time then
    M.stop()
  else
    M.start()
  end
end

return M
