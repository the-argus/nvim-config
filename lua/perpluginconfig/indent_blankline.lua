local indent_blankline_ok, indent_blankline = pcall(require, "ibl")
local indent_blankline_hooks_ok, indent_blankline_hooks = pcall(require, "ibl.hooks")
if not indent_blankline_ok or not indent_blankline_hooks_ok then
    return
end

local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
}

-- NOTE: in the suggested settings there is a hook registered here, where we
-- set the values of rainbow_delimiters colors whenever highlight gets set up.
-- but we don't customize rainbow_delimiters colors at all so I believe this
-- can be ignored

vim.g.rainbow_delimiters = { highlight = highlight }

indent_blankline.setup { scope = { highlight = highlight } }

indent_blankline_hooks.register(indent_blankline_hooks.type.SCOPE_HIGHLIGHT,
    indent_blankline_hooks.builtin.scope_highlight_from_extmark)
