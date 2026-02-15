local present, substitute = pcall(require, "substitute")

if not present then
    vim.notify("failed to load substitute")
    return
end

vim.keymap.set("n", "s", require('substitute').operator, { noremap = true })
vim.keymap.set("n", "ss", require('substitute').line, { noremap = true })
vim.keymap.set("n", "S", require('substitute').eol, { noremap = true })
vim.keymap.set("x", "s", require('substitute').visual, { noremap = true })

-- substitute in range: do the command followed by two motions, the first one selecting some text and the second ones to select lines to find and replace
-- example: <leader>siwip will substitute all instances of the inner word (iw) found in the inner paragraph (ip)
vim.keymap.set("n", "<leader>s", require('substitute.range').operator, { noremap = true })
vim.keymap.set("x", "<leader>s", require('substitute.range').visual, { noremap = true })
vim.keymap.set("n", "<leader>ss", require('substitute.range').word, { noremap = true })

local config = {
    on_substitute = nil,
    yank_substitued_text = false,
    range = {
        prefix = "s",
        prompt_current_text = false,
        confirm = false,
        complete_word = false,
        motion1 = false,
        motion2 = false,
    },
    exchange = {
        motion = false,
    },
}

substitute.setup(config)
