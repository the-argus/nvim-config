local present, precognition = pcall(require, "precognition")
if not present then
    return
end

precognition.setup()

vim.keymap.set("n", "<Leader>pp", "<Cmd>Precognition toggle<CR>", { desc = "Toggle inline motion hints", silent = true })
