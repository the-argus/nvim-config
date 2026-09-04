local substitute_ok, substitute = pcall(require, "substitute")
local substitute_range_ok, substitute_range = pcall(require, "substitute.range")
local substitute_exchange_ok, substitute_exchange = pcall(require, "substitute.exchange")
if not substitute_ok or not substitute_range_ok or not substitute_exchange_ok then
    return
end

-- motions for substituting the following text object with the contents of the main register
vim.keymap.set("n", "s", substitute.operator, { noremap = true })
vim.keymap.set("n", "ss", substitute.line, { noremap = true })
vim.keymap.set("x", "s", substitute.visual, { noremap = true })

-- actions for doing <Leader>s<motion1><motion2> in order to select a range of
-- text (motion1) and then perform a substitution on all the text objects that
-- would be selected by motion2.
vim.keymap.set("n", "<leader>s", substitute_range.operator, { noremap = true })
vim.keymap.set("x", "<leader>s", substitute_range.visual, { noremap = true })
vim.keymap.set("n", "<leader>ss", substitute_range.word, { noremap = true })

-- motions for exchanging the contents of the current register and and text
-- object, basically toggling between a state of "put this text object in the
-- exchange register and remember its location" and "replace this text object
-- with whatever is in the exchange register and swap it with the original
-- location, and clear the exchange register and remembered location".
vim.keymap.set("n", "sx", substitute_exchange.operator, { noremap = true })
vim.keymap.set("n", "sxx", substitute_exchange.line, { noremap = true })
vim.keymap.set("x", "X", substitute_exchange.visual, { noremap = true })
-- cancel whatever is currently remembered as the exchange target. Escape also works
vim.keymap.set("n", "sxc", substitute_exchange.cancel, { noremap = true })

-- defaults are fine
substitute.setup({})
