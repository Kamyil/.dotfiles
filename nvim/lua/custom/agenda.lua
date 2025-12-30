local M = {}

local weekly_dir = vim.fn.expand('~/second-brain/weekly')

local state = {
  today_expanded = true,
  week_expanded = true,
}

local function parse_date(date_str)
  local year, month, day = date_str:match('(%d%d%d%d)%-(%d%d)%-(%d%d)')
  if year and month and day then
    return os.time({ year = tonumber(year), month = tonumber(month), day = tonumber(day) })
  end
  return nil
end

local function format_date(timestamp)
  return os.date('%Y-%m-%d', timestamp)
end

local function format_display_date(timestamp, today)
  local diff_days = math.floor((timestamp - today) / (24 * 60 * 60))
  local weekday = os.date('%A', timestamp)
  local date_str = os.date('%Y-%m-%d', timestamp)

  if diff_days == 0 then
    return string.format('Today (%s, %s)', weekday, date_str)
  elseif diff_days == 1 then
    return string.format('Tomorrow (%s, %s)', weekday, date_str)
  elseif diff_days == -1 then
    return string.format('Yesterday (%s, %s)', weekday, date_str)
  elseif diff_days > 0 then
    return string.format('%s (%s) - in %d days', weekday, date_str, diff_days)
  else
    return string.format('%s (%s) - %d days ago', weekday, date_str, -diff_days)
  end
end

local function scan_weekly_files()
  local tasks = {}
  local files = vim.fn.glob(weekly_dir .. '/*.md', false, true)

  for _, filepath in ipairs(files) do
    local file = io.open(filepath, 'r')
    if file then
      local line_num = 0
      for line in file:lines() do
        line_num = line_num + 1

        local is_todo = line:match('^%s*%- %[ %]') or line:match('^%s*%- %[%-%]')
        if is_todo then
          local scheduled = line:match('@scheduled%((%d%d%d%d%-%d%d%-%d%d)%)')
          local deadline = line:match('@deadline%((%d%d%d%d%-%d%d%-%d%d)%)')

          if scheduled or deadline then
            local task_text = line:gsub('^%s*%- %[.%]%s*', ''):gsub('%s*@scheduled%([^)]+%)', ''):gsub('%s*@deadline%([^)]+%)', '')
            task_text = vim.trim(task_text)

            local task = {
              text = task_text,
              scheduled = scheduled,
              deadline = deadline,
              deadline_ts = deadline and parse_date(deadline) or nil,
              filepath = filepath,
              line = line_num,
              is_in_progress = line:match('^%s*%- %[%-%]') ~= nil,
            }

            if scheduled then
              local ts = parse_date(scheduled)
              if ts then
                table.insert(tasks, vim.tbl_extend('force', task, { date = ts, date_type = 'scheduled' }))
              end
            end

            if deadline then
              local ts = parse_date(deadline)
              if ts then
                if not scheduled or scheduled ~= deadline then
                  table.insert(tasks, vim.tbl_extend('force', task, { date = ts, date_type = 'deadline' }))
                else
                  tasks[#tasks].date_type = 'both'
                end
              end
            end
          end
        end
      end
      file:close()
    end
  end

  table.sort(tasks, function(a, b) return a.date < b.date end)
  return tasks
end

local function format_task_line(task, today)
  local prefix = task.is_in_progress and '    [-] ' or '    [ ] '
  local suffix = ''

  if task.date_type == 'scheduled' then
    suffix = ' 📌'
  else
    local days_left = math.floor((task.deadline_ts - today) / (24 * 60 * 60))
    local urgency_icon
    if days_left <= 1 then
      urgency_icon = '🔴'
    elseif days_left <= 4 then
      urgency_icon = '🟡'
    else
      urgency_icon = '🟢'
    end

    local days_text
    if days_left < 0 then
      days_text = string.format('%d days overdue', -days_left)
    elseif days_left == 0 then
      days_text = 'today'
    elseif days_left == 1 then
      days_text = '1 day left'
    else
      days_text = string.format('%d days left', days_left)
    end

    if task.date_type == 'both' then
      suffix = string.format(' 📌 %s %s', urgency_icon, days_text)
    else
      suffix = string.format(' %s %s', urgency_icon, days_text)
    end
  end

  return prefix .. task.text .. suffix
end

local function build_agenda_lines(tasks)
  local lines = {}
  local task_map = {}
  local section_lines = {}
  local today = os.time({ year = tonumber(os.date('%Y')), month = tonumber(os.date('%m')), day = tonumber(os.date('%d')) })
  local today_str = format_date(today)
  local week_end = today + (7 * 24 * 60 * 60)

  local today_tasks = {}
  local overdue_tasks = {}
  local week_tasks = {}

  for _, task in ipairs(tasks) do
    local task_date_str = format_date(task.date)
    if task_date_str == today_str then
      table.insert(today_tasks, task)
    elseif task.date < today then
      table.insert(overdue_tasks, task)
    elseif task.date > today and task.date <= week_end then
      table.insert(week_tasks, task)
    end
  end

  table.insert(lines, '📅 Agenda')
  table.insert(lines, string.rep('─', 60))
  table.insert(lines, '')

  local today_icon = state.today_expanded and '▼' or '▶'
  local today_count = #today_tasks + #overdue_tasks
  local today_header = string.format('%s  Today (%d tasks)', today_icon, today_count)
  table.insert(lines, today_header)
  section_lines.today_header = #lines

  if state.today_expanded then
    if #overdue_tasks > 0 then
      for _, task in ipairs(overdue_tasks) do
        local prefix = task.is_in_progress and '[-]' or '[ ]'
        local line = string.format('  ⚠️ %s: %s %s', format_date(task.date), task.text, prefix)
        table.insert(lines, line)
        task_map[#lines] = task
      end
    end

    if #today_tasks > 0 then
      for _, task in ipairs(today_tasks) do
        local task_line = format_task_line(task, today)
        table.insert(lines, task_line)
        task_map[#lines] = task
      end
    end

    if #today_tasks == 0 and #overdue_tasks == 0 then
      table.insert(lines, '    No tasks for today')
    end
  end

  table.insert(lines, '')

  local week_icon = state.week_expanded and '▼' or '▶'
  local week_header = string.format('%s  This Week (%d tasks)', week_icon, #week_tasks)
  table.insert(lines, week_header)
  section_lines.week_header = #lines

  if state.week_expanded then
    if #week_tasks > 0 then
      local current_date = nil
      for _, task in ipairs(week_tasks) do
        local task_date = format_date(task.date)
        if task_date ~= current_date then
          current_date = task_date
          local display = format_display_date(task.date, today)
          table.insert(lines, '  ' .. display)
        end
        local task_line = format_task_line(task, today)
        table.insert(lines, task_line)
        task_map[#lines] = task
      end
    else
      table.insert(lines, '    No tasks this week')
    end
  end

  table.insert(lines, '')
  table.insert(lines, string.rep('─', 60))
  table.insert(lines, '📌 = scheduled  🔴 ≤1d  🟡 2-4d  🟢 >4d  ⚠️ = overdue')
  table.insert(lines, '<Enter> jump  <Tab> toggle section  <Esc>/<q> close')

  return lines, task_map, section_lines
end

local function refresh_agenda(buf, win)
  local tasks = scan_weekly_files()
  local lines, task_map, section_lines = build_agenda_lines(tasks)

  vim.api.nvim_set_option_value('modifiable', true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })

  local height = math.min(#lines, 30)
  vim.api.nvim_win_set_height(win, height)

  vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
  for i, line in ipairs(lines) do
    if line:match('^📅') or line:match('^─') then
      vim.api.nvim_buf_add_highlight(buf, -1, 'Title', i - 1, 0, -1)
    elseif line:match('^[▼▶]') then
      vim.api.nvim_buf_add_highlight(buf, -1, 'Function', i - 1, 0, -1)
    elseif line:match('^  ⚠️') then
      vim.api.nvim_buf_add_highlight(buf, -1, 'DiagnosticError', i - 1, 0, -1)
    elseif line:match('^  %a') then
      vim.api.nvim_buf_add_highlight(buf, -1, 'Comment', i - 1, 0, -1)
    elseif line:match('🔴') then
      vim.api.nvim_buf_add_highlight(buf, -1, 'DiagnosticWarn', i - 1, 0, -1)
    end
  end

  return task_map, section_lines
end

function M.open()
  local tasks = scan_weekly_files()
  local lines, task_map, section_lines = build_agenda_lines(tasks)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
  vim.api.nvim_set_option_value('filetype', 'agenda', { buf = buf })

  local width = 70
  local height = math.min(#lines, 30)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Agenda ',
    title_pos = 'center',
  })

  vim.api.nvim_set_option_value('cursorline', true, { win = win })
  vim.api.nvim_set_option_value('wrap', false, { win = win })

  local current_task_map = task_map
  local current_section_lines = section_lines

  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true })

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true })

  vim.keymap.set('n', '<CR>', function()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local line_num = cursor[1]
    local task = current_task_map[line_num]

    if task then
      vim.api.nvim_win_close(win, true)
      vim.cmd('edit ' .. task.filepath)
      vim.api.nvim_win_set_cursor(0, { task.line, 0 })
      vim.cmd('normal! zz')
    end
  end, { buffer = buf, nowait = true })

  vim.keymap.set('n', '<Tab>', function()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local line_num = cursor[1]

    if line_num == current_section_lines.today_header then
      state.today_expanded = not state.today_expanded
      current_task_map, current_section_lines = refresh_agenda(buf, win)
    elseif line_num == current_section_lines.week_header then
      state.week_expanded = not state.week_expanded
      current_task_map, current_section_lines = refresh_agenda(buf, win)
    end
  end, { buffer = buf, nowait = true })

  for i, line in ipairs(lines) do
    if line:match('^📅') or line:match('^─') then
      vim.api.nvim_buf_add_highlight(buf, -1, 'Title', i - 1, 0, -1)
    elseif line:match('^[▼▶]') then
      vim.api.nvim_buf_add_highlight(buf, -1, 'Function', i - 1, 0, -1)
    elseif line:match('^  ⚠️') then
      vim.api.nvim_buf_add_highlight(buf, -1, 'DiagnosticError', i - 1, 0, -1)
    elseif line:match('^  %a') then
      vim.api.nvim_buf_add_highlight(buf, -1, 'Comment', i - 1, 0, -1)
    elseif line:match('🔴') then
      vim.api.nvim_buf_add_highlight(buf, -1, 'DiagnosticWarn', i - 1, 0, -1)
    end
  end
end

return M
