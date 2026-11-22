local okay, gitsigns = pcall(require, 'gitsigns')

if not okay then
    return
end

local config = {
    signs                        = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
    },
    signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir                 = {
        follow_files = true
    },
    attach_to_untracked          = true,
    current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts      = {
        virt_text = true,
        virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
    },
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
    sign_priority                = 6,
    update_debounce              = 100,
    status_formatter             = nil, -- Use default
    max_file_length              = 40000,
    preview_config               = {
        -- Options passed to nvim_open_win
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
    },
}

gitsigns.setup(config)

vim.keymap.set("n", "]h", "<Cmd>Gitsigns next_hunk<CR>",
    { desc = "Jump to next uncommitted hunk in the current file", silent = true })
vim.keymap.set("n", "[h", "<Cmd>Gitsigns prev_hunk<CR>",
    { desc = "Jump to previous uncommitted hunk in the current file", silent = true })

---@param line_range [integer, integer]|nil
local function gitsigns_toggle_staging(line_range)
    local buf = vim.api.nvim_get_current_buf()

    -- gitsigns doesn't recognize if hunks were added while it was attached,
    -- and I like to use external git commands, so we can unattach and reattach
    -- to refresh things
    gitsigns.detach(buf)
    gitsigns.attach(buf, nil, nil, function()
        vim.schedule(function()
            if vim.api.nvim_get_current_buf() == buf then
                gitsigns.stage_hunk(line_range)
            end
        end)
    end)
end
vim.keymap.set("n", "<Leader>vs", function() gitsigns_toggle_staging(nil) end,
    { desc = "Toggle whether hunk under cursor is staged" })
vim.keymap.set("x", "<Leader>vs", function()
    local cursor_line, selection_start_line = vim.fn.line("."), vim.fn.line("v")
    gitsigns_toggle_staging({
        math.min(cursor_line, selection_start_line),
        math.max(cursor_line, selection_start_line),
    })
end, { desc = "Stage the selected lines, or unstage them if they are already staged" })
vim.keymap.set("n", "<Leader>vS", function() gitsigns.stage_buffer() end,
    { desc = "git-add this file" })
vim.keymap.set("n", "<Leader>vU", function() gitsigns.reset_buffer_index() end,
    { desc = "git-reset this file" })
