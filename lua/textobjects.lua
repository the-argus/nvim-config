---taken from https://github.com/dotcore64/nvim-in-its-entirety
---safe to call from visual mode and operator pending mode
function entire_buffer()
    -- set previous context mark to work with <C-o>
    vim.cmd.normal({ "m'", bang = true })

    local buf = 0

    local start_row, start_col = 0, 0
    local end_row = vim.api.nvim_buf_line_count(buf) - 1
    local last_line_content = vim.api.nvim_buf_get_lines(buf, end_row, end_row + 1, true)[1] or ''
    local end_col = math.max(0, #last_line_content)

    -- Enter Visual mode if needed.
    -- Operators only apply if the mapping terminates in Visual mode.
    local mode = vim.api.nvim_get_mode().mode
    if mode ~= 'V' and mode ~= 'v' and mode ~= '\22' then
        vim.cmd.normal({ 'V', bang = true })
    end

    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
    vim.cmd.normal({ 'o', bang = true }) -- Swap cursor to other end (:help v_o)
    vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col })
end

vim.keymap.set({ "x", "o" }, "ae", entire_buffer, { desc = "Entire buffer" })
