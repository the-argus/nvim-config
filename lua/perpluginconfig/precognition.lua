local present, precognition = pcall(require, "precognition")
if not present then
    return
end

precognition.setup({ startVisible = false })

vim.keymap.set("n", "<C-c>", precognition.peek,
    { desc = "Peek at inline motion hints", silent = true })
