-- extra text objects such as if (inner function call), af (around function
-- call), ia (inner argument), aa (around argument)
local ai_present, ai = pcall(require, "mini.ai")
if ai_present then
    ai.setup()
end

-- makes it so that typing an opening brace or quote also types the closing one
local pairs_present, mini_pairs = pcall(require, "mini.pairs")
if pairs_present then
    mini_pairs.setup()
end

-- do square brackets followed by a letter to do next/prev of that thing.
-- b (buffers) d(diagnostics) c(comment) q(quickfix)
local bracketed_present, bracketed = pcall(require, "mini.bracketed")
if bracketed_present then
    bracketed.setup()
end

-- file explorer popup
-- <Leader>f : toggle file explorer
-- TODO: probably just remove the current file stuff and always open at cwd
local files_present, files = pcall(require, "mini.files")
if files_present then
    files.setup({
        windows = { preview = true },
    })

    -- stretch the windows to the full editor height (widths are set on open)
    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesWindowUpdate",
        callback = function(args)
            local config = vim.api.nvim_win_get_config(args.data.win_id)
            config.height = vim.o.lines - 4 -- borders, statusline, cmdline
            vim.api.nvim_win_set_config(args.data.win_id, config)
        end,
    })

    vim.keymap.set("n", "<Leader>f", function()
        if not files.close() then
            local path = vim.api.nvim_buf_get_name(0)
            if vim.fn.filereadable(path) == 0 then
                path = nil
            end
            local usable = vim.o.columns - 8
            local width_nofocus = math.floor(usable * 0.15)
            local width_focus = math.floor(usable * 0.30)
            files.open(path, true, {
                windows = {
                    width_nofocus = width_nofocus,
                    width_focus = width_focus,
                    width_preview = usable - width_focus - width_nofocus,
                },
            })
        end
    end)
end

-- move visual selection with alt + hjkl
local move_present, move = pcall(require, "mini.move")
if move_present then
    move.setup({
        mappings = {
            -- disable moving a line in normal mode because the default bindings
            -- are the same as my Alt-hjkl window focus moving bindings
            line_left = "",
            line_right = "",
            line_down = "",
            line_up = "",
        },
    })
end
