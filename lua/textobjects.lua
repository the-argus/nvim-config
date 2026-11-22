-- select an area of a buffer given in coordinates
local function select_range(visual_mode, start_row, start_column, end_row, end_column)
    if vim.api.nvim_get_mode().mode ~= visual_mode then
        vim.cmd.normal({ visual_mode, bang = true })
    end
    vim.api.nvim_win_set_cursor(0, { start_row, start_column })
    vim.cmd.normal({ 'o', bang = true })
    vim.api.nvim_win_set_cursor(0, { end_row, end_column })
end

-- get the treesitter node representing the indentation level the cursor is
-- currently at. this should be the same one highlighted by indent-blankline
local function get_node_for_current_scope()
    local scope_ok, scope = pcall(require, "ibl.scope")
    local config_ok, config = pcall(require, "ibl.config")
    if not scope_ok or not config_ok then
        return nil
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not parser_ok or not parser then
        return nil
    end
    -- parsing should have already happened and been cached so in theory this
    -- doesn't cause performance issues
    parser:parse()
    local ok, node = pcall(scope.get, bufnr, config.get_config(bufnr))
    if not ok or not node then
        return nil
    end

    return node
end

local function scope_textobject(around)
    return function()
        local node = get_node_for_current_scope()
        if not node then
            return
        end
        local start_row, start_col, end_row, end_col = node:range()
        -- fix the numbers because rows are one-based and end_col is inclusive
        start_row, end_row, end_col = start_row + 1, end_row + 1, end_col - 1
        -- fix row ending with newline
        if end_col < 0 and end_row > start_row then
            end_row = end_row - 1
            end_col = math.max(#vim.fn.getline(end_row) - 1, 0)
        end

        if around then
            select_range("V", start_row, 0, end_row, 0)
            return
        end

        -- for inner we select from the second line of the scope (so not
        -- including braces, function decl, etc) and end at the last line that
        -- is more indented than the closing brace / end of the scope
        local indent = vim.fn.indent(start_row)
        local last = end_row
        while last > start_row do
            local text = vim.fn.getline(last)
            if text:match("%S") and vim.fn.indent(last) > indent then
                break
            end
            last = last - 1
        end
        if last == start_row then
            -- just do selection charwise if it seems like the scope is all on one line
            select_range("v", start_row, start_col, end_row, math.max(end_col, 0))
            return
        end
        select_range("V", start_row + 1, 0, last, 0)
    end
end

vim.keymap.set({ "x", "o" }, "ii", scope_textobject(false), { desc = "inner indent-blankline scope" })
vim.keymap.set({ "x", "o" }, "ai", scope_textobject(true), { desc = "around indent-blankline scope" })
