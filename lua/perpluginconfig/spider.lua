local present, spider = pcall(require, "spider")
if not present then
    return
end

-- NOTE: this has to run after precognition is set up
spider.setup()

vim.keymap.set({ "n", "o", "x" }, "M", "<Nop>", { desc = "Subword motion prefix" })
vim.keymap.set({ "n", "o", "x" }, "Mw", "<Cmd>lua require('spider').motion('w')<CR>",
    { desc = "Subword w", silent = true })
vim.keymap.set({ "n", "o", "x" }, "Me", "<Cmd>lua require('spider').motion('e')<CR>",
    { desc = "Subword e", silent = true })
vim.keymap.set({ "n", "o", "x" }, "Mb", "<Cmd>lua require('spider').motion('b')<CR>",
    { desc = "Subword b", silent = true })
vim.keymap.set({ "n", "o", "x" }, "Mge", "<Cmd>lua require('spider').motion('ge')<CR>",
    { desc = "Subword ge", silent = true })
