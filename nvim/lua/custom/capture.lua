local M = {}

local second_brain = vim.fn.expand('~/second-brain')
local weekly_dir = second_brain .. '/weekly'

local function get_current_week_file()
  local handle = io.popen('date +%G')
  local year = handle:read('*a'):gsub('%s+', '')
  handle:close()

  handle = io.popen('date +%V')
  local week = handle:read('*a'):gsub('%s+', '')
  handle:close()

  return weekly_dir .. '/' .. year .. '-W' .. week .. '.md'
end

local function parse_relative_date(text)
  local now = os.time()
  local day_seconds = 24 * 60 * 60

  local lower = text:lower()

  if lower == 'today' then
    return os.date('%Y-%m-%d', now)
  elseif lower == 'tomorrow' then
    return os.date('%Y-%m-%d', now + day_seconds)
  elseif lower == 'yesterday' then
    return os.date('%Y-%m-%d', now - day_seconds)
  end

  local days = lower:match('^%+(%d+)d$')
  if days then
    return os.date('%Y-%m-%d', now + tonumber(days) * day_seconds)
  end

  local weeks = lower:match('^%+(%d+)w$')
  if weeks then
    return os.date('%Y-%m-%d', now + tonumber(weeks) * 7 * day_seconds)
  end

  local weekday_names = {
    sunday = 0, monday = 1, tuesday = 2, wednesday = 3,
    thursday = 4, friday = 5, saturday = 6,
    sun = 0, mon = 1, tue = 2, wed = 3, thu = 4, fri = 5, sat = 6,
  }

  local next_day = lower:match('^next%s+(%w+)$')
  if next_day and weekday_names[next_day] then
    local target_wday = weekday_names[next_day]
    local current_wday = tonumber(os.date('%w', now))
    local days_until = (target_wday - current_wday) % 7
    if days_until == 0 then days_until = 7 end
    return os.date('%Y-%m-%d', now + days_until * day_seconds)
  end

  return text
end

local function expand_dates(text)
  text = text:gsub('@scheduled%(([^)]+)%)', function(date_str)
    return '@scheduled(' .. parse_relative_date(date_str) .. ')'
  end)

  text = text:gsub('@deadline%(([^)]+)%)', function(date_str)
    return '@deadline(' .. parse_relative_date(date_str) .. ')'
  end)

  return text
end

local function find_capture_section_line(lines)
  for i, line in ipairs(lines) do
    if line:match('^## Capture') then
      return i
    end
  end
  return nil
end

local function append_to_capture_section(file_path, task_text)
  local expanded_text = expand_dates(task_text)

  local file = io.open(file_path, 'r')
  if not file then
    vim.notify('Could not open weekly note: ' .. file_path, vim.log.levels.ERROR)
    return false
  end

  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()

  local capture_line = find_capture_section_line(lines)
  if not capture_line then
    vim.notify('No "## Capture" section found in weekly note', vim.log.levels.ERROR)
    return false
  end

  local insert_line = capture_line + 1
  while insert_line <= #lines and lines[insert_line]:match('^%s*$') do
    insert_line = insert_line + 1
  end

  local new_task = '- [ ] ' .. expanded_text
  table.insert(lines, insert_line, new_task)

  file = io.open(file_path, 'w')
  if not file then
    vim.notify('Could not write to weekly note: ' .. file_path, vim.log.levels.ERROR)
    return false
  end

  for _, line in ipairs(lines) do
    file:write(line .. '\n')
  end
  file:close()

  return true
end

function M.capture()
  local week_file = get_current_week_file()

  vim.ui.input({ prompt = '📝 Capture: ' }, function(input)
    if not input or input == '' then
      return
    end

    if append_to_capture_section(week_file, input) then
      vim.notify('✓ Captured to weekly note', vim.log.levels.INFO)
    end
  end)
end

function M.capture_with_schedule()
  local week_file = get_current_week_file()

  vim.ui.input({ prompt = '📝 Capture (use @scheduled(tomorrow), @deadline(+3d), etc.): ' }, function(input)
    if not input or input == '' then
      return
    end

    if append_to_capture_section(week_file, input) then
      vim.notify('✓ Captured to weekly note', vim.log.levels.INFO)
    end
  end)
end

M.expand_dates = expand_dates
M.parse_relative_date = parse_relative_date

return M
