local indent_blankline_ok, indent_blankline = pcall(require, "ibl")
local indent_blankline_hooks_ok, indent_blankline_hooks = pcall(require, "ibl.hooks")
if not indent_blankline_ok or not indent_blankline_hooks_ok then
    return
end

local highlight = {
    "RainbowDelimiterRed",
    "RainbowDelimiterYellow",
    "RainbowDelimiterBlue",
    "RainbowDelimiterOrange",
    "RainbowDelimiterGreen",
    "RainbowDelimiterViolet",
    "RainbowDelimiterCyan",
}

-- indent blankline does not work if the highlight groups do not exist yet.
-- but rainbow delimiters does not set up its highlight groups until after
-- plugins have loaded, which doesn't happen until after user init.lua runs.
-- Solve this by deferring setup until VimEnter
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        indent_blankline.setup { scope = { highlight = highlight } }

        indent_blankline_hooks.register(indent_blankline_hooks.type.SCOPE_HIGHLIGHT,
            indent_blankline_hooks.builtin.scope_highlight_from_extmark)
    end,
})
