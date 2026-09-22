local present, spider = pcall(require, "spider")
if not present then
    return
end

-- NOTE: this has to run after precognition is set up
spider.setup()

vim.keymap.set({ "n", "o", "x" }, "w", "<Cmd>lua require('spider').motion('w')<CR>",
    { desc = "Spider w", silent = true })
vim.keymap.set({ "n", "o", "x" }, "e", "<Cmd>lua require('spider').motion('e')<CR>",
    { desc = "Spider e", silent = true })
vim.keymap.set({ "n", "o", "x" }, "b", "<Cmd>lua require('spider').motion('b')<CR>",
    { desc = "Spider b", silent = true })
vim.keymap.set({ "n", "o", "x" }, "ge", "<Cmd>lua require('spider').motion('ge')<CR>",
    { desc = "Spider ge", silent = true })
