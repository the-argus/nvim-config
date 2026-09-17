-- extra text objects such as if (inner function call), af (around function
-- call), ia (inner argument), aa (around argument)
local ai_present, ai = pcall(require, "mini.ai")
if ai_present then
    ai.setup(
        {
            -- TODO: migrate text objects from other providers and others such as `ae` to this
            -- see `:h MiniAi.config`.
            custom_textobjects = {},
        }
    )
end

-- makes it so that typing an opening brace or quote also types the closing one
-- but with some additional smart stuff to try to guess when the cursor is
-- already inside a string or not
local pairs_present, mini_pairs = pcall(require, "mini.pairs")
if pairs_present then
    -- %s is whitespace + newline
    -- % is lua equivalent of \ (escape character)
    -- the "after" pattern matches any whitespace, newline, or closing brace
    -- that comes after the cursor.
    -- The open/quote/apostrophe patterns match something *before* the cursor,
    -- by using the caret ^ which makes the pattern search backwards, starting
    -- in the area that mini.pairs searches, which the character before and
    -- after the cursor.
    local after = "[%s%)%]%}]"
    local open = "^[^\\]" .. after
    local quote = "^[^\\]" .. after
    local apostrophe = "^[^%a\\]" .. after  -- keep mini's "not after a letter" rule

    mini_pairs.setup({
        mappings = {
            ["("] = { action = "open", pair = "()", neigh_pattern = open },
            ["["] = { action = "open", pair = "[]", neigh_pattern = open },
            ["{"] = { action = "open", pair = "{}", neigh_pattern = open },

            ['"'] = { action = "closeopen", pair = '""', neigh_pattern = quote, register = { cr = false } },
            ["'"] = { action = "closeopen", pair = "''", neigh_pattern = apostrophe, register = { cr = false } },
            ["`"] = { action = "closeopen", pair = "``", neigh_pattern = quote, register = { cr = false } },
        },
    })

    local function neighboring_chars()
        local line = "\r" .. (vim.api.nvim_get_current_line():gsub("%z", " ")) .. "\n"
        local start = vim.fn.charcol(".") - 1
        return vim.fn.strcharpart(line, start, 1), vim.fn.strcharpart(line, start + 1, 1)
    end

    --- try to ask treesitter if we are inside of a string or not. we only
    --- trust a positive response as there may be false negatives. In those
    --- cases we fall back to just counting the number of quotes on the line
    local function inside_string(char)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local ok, node = pcall(vim.treesitter.get_node, { pos = { row - 1, math.max(col - 1, 0) } })
        if ok and node then
            local node_type = node:type()
            local inside = node_type:match("string") and (node_type:find("content", 1, true) or node_type:find("fragment", 1, true))
            local errored = false
            while node do
                errored = errored or node:type() == "ERROR"
                node = node:parent()
            end
            if inside and not errored then
                return true
            end
        end

        -- odd number of unescaped quotes == inside a string
        local before = vim.fn.strcharpart(vim.api.nvim_get_current_line(), 0, vim.fn.charcol(".") - 1)
        before = before:gsub("\\.", "") -- an escaped quote does not open or close anything
        local _, count = before:gsub(vim.pesc(char), "")
        return count % 2 == 1
    end

    -- wrapper for typing quotes or single quotes which sort of manually does
    -- what mini pairs does, except it is smarter and tries not to insert
    -- another quote if we are already in a string
    for _, spec in ipairs({ { '"', quote }, { "'", apostrophe }, { "`", quote } }) do
        local char, neigh_pattern = spec[1], spec[2]
        vim.keymap.set("i", char, function()
            local _, right = neighboring_chars()
            if right ~= char and inside_string(char) then
                return char
            end
            return mini_pairs.closeopen(char .. char, neigh_pattern)
        end, { expr = true, replace_keycodes = false, desc = "mini.pairs closeopen " .. char .. char })
    end
end

-- do square brackets followed by a letter to do next/prev of that thing.
-- b (buffers) d(diagnostics) c(comment) q(quickfix)
local bracketed_present, bracketed = pcall(require, "mini.bracketed")
if bracketed_present then
    bracketed.setup({
        -- keeping comment (c), conflict (x), diagnostic (d), indent change (i) quickfix (q), everything else disabled
        buffer     = { suffix = '', options = {} },
        file       = { suffix = '', options = {} },
        jump       = { suffix = '', options = {} },
        location   = { suffix = '', options = {} },
        oldfile    = { suffix = '', options = {} },
        treesitter = { suffix = '', options = {} },
        undo       = { suffix = '', options = {} },
        window     = { suffix = '', options = {} },
        yank       = { suffix = '', options = {} },
    })
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

local comment_present, comment = pcall(require, "mini.comment")
if comment_present then
    comment.setup({ mappings = { textobject = 'ic' } })
end
