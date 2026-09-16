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

local popups = require("perpluginconfig.popups")

vim.keymap.set("n", "<Leader>f", function()
    popups.close_telescope() -- mini.files + tele should be mutually exclusive
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

local function show_hidden(_)
    return true
end

local function hide_hidden(fs_entry)
    return not vim.startswith(fs_entry.name, ".")
end

-- modify the currently active filter. could also probably modify a variable
-- that the filter looks at, this seems cleaner though
local function toggle_hidden()
    files.config.content.filter = files.config.content.filter ~= hide_hidden and hide_hidden or show_hidden
    files.refresh({ content = { filter = files.config.content.filter } })
end

vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
        local buf = args.data.buf_id
        vim.keymap.set("n", "zh", toggle_hidden, { buffer = buf, desc = "Toggle hidden files" })
        -- mini files only allows for binding one key per thing, so just do a
        -- general keybind while in a mini files buffer that calls the function
        -- manually
        vim.keymap.set("n", "<CR>", function() files.go_in({ close_on_file = true }) end,
            { buffer = buf, desc = "Go in, closing the explorer when it is a file" })
    end,
})
