local present, substitute = pcall(require, "substitute")

if not present then
    vim.notify("failed to load substitute")
    return
end

-- keymapings
vim.api.nvim_set_keymap("n", "s", "<cmd>lua require('substitute').operator()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "ss", "<cmd>lua require('substitute').line()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "S", "<cmd>lua require('substitute').eol()<cr>", { noremap = true })
vim.api.nvim_set_keymap("x", "s", "<cmd>lua require('substitute').visual()<cr>", { noremap = true })

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
