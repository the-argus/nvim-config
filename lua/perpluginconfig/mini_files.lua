local files_ok, files = pcall(require, "mini.files")
if not files_ok then
    return;
end

-- Default mappings in setup below:
-- close       = 'q',
-- go_in       = 'l',
-- go_in_plus  = 'L',
-- go_out      = 'h',
-- go_out_plus = 'H',
-- mark_goto   = "'",
-- mark_set    = 'm',
-- reset       = '<BS>',
-- reveal_cwd  = '@',
-- show_help   = 'g?',
-- synchronize = '=',
-- trim_left   = '<',
-- trim_right  = '>',

files.setup({
    windows = {
        preview = true
    },

    -- also has options for: file sorting function, file filtering function,
    -- window focus width, window unfocused width, preview window width,
    -- whether to use as default file explorer (hijack netrw), whether to
    -- permanently delete files or move them to a trash (true by default) and
    -- timeout for lsp requests (1000ms default)
})

-- keep window size the size of the window minus a bit for margins
vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesWindowUpdate",
    callback = function(args)
        local config = vim.api.nvim_win_get_config(args.data.win_id)
        config.height = vim.o.lines - 4
        vim.api.nvim_win_set_config(args.data.win_id, config)
    end,
})

-- file explorer popup
vim.keymap.set("n", "<Leader>f", function()
    if not files.close() then
        local path = vim.api.nvim_buf_get_name(0)
        if vim.fn.filereadable(path) == 0 then
            path = nil
        end
        local width = vim.o.columns - 8
        local width_nofocus = math.floor(width * 0.15)
        local width_focus = math.floor(width * 0.30)
        files.open(path, true, {
            windows = {
                width_nofocus = width_nofocus,
                width_focus = width_focus,
                width_preview = width - width_focus - width_nofocus,
            },
        })
    end
end)
