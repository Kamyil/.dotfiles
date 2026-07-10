-- Copy path to clipboard
vim.api.nvim_create_user_command('Cppath', function()
	local path = vim.fn.expand('%:p')
	vim.fn.setreg('+', path)
	vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

-- Live markdown preview using Kitty's text sizing protocol (OSC 66).
-- Opens a vertical split that auto-refreshes as you edit. The preview renders
-- h1-h6 at proportionally larger font sizes (6x down to 2x base font).
-- Requires kitty >= 0.40.0. Close the preview window to stop auto-refresh.
vim.api.nvim_create_user_command('MarkdownPreview', function()
    local buf = vim.api.nvim_get_current_buf()
    local tmp = vim.fn.tempname() .. '.md'
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    vim.fn.writefile(lines, tmp)
    local script = vim.fn.expand('~/.dotfiles/scripts/kitty-markdown-live.py')
    local src_win = vim.api.nvim_get_current_win()

    -- Open terminal running the live preview watcher
    vim.cmd('belowright vsplit | terminal python3 -u ' .. script .. ' ' .. tmp)
    local preview_buf = vim.api.nvim_get_current_buf()
    local preview_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(src_win)

    -- Auto-refresh preview on each text change
    local augroup = vim.api.nvim_create_augroup('MarkdownPreview' .. buf, { clear = true })
    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufWritePost' }, {
        group = augroup,
        buffer = buf,
        callback = function()
            if vim.api.nvim_win_is_valid(preview_win) then
                local updated = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                vim.fn.writefile(updated, tmp)
            else
                -- Preview window was closed — clean up
                vim.api.nvim_del_augroup_by_id(augroup)
                pcall(vim.fn.delete, tmp)
            end
        end,
    })

    -- Clean up temp file when preview buffer is closed
    vim.api.nvim_create_autocmd('BufWipeout', {
        buffer = preview_buf,
        once = true,
        callback = function()
            vim.api.nvim_del_augroup_by_id(augroup)
            pcall(vim.fn.delete, tmp)
        end,
    })
end, { desc = 'Live markdown preview with variable font sizes (Kitty OSC 66)' })

