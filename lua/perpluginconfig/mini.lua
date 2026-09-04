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
