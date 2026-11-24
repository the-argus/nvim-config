local okay, various_textobjs = pcall(require, "various-textobjs")

if not okay then
    return
end

vim.keymap.set({ "o", "x" }, "iM", function() various_textobjs.subword("inner") end, { desc = "inner subword" })
vim.keymap.set({ "o", "x" }, "aM", function() various_textobjs.subword("outer") end, { desc = "a subword" })
vim.keymap.set({ "o", "x" }, "ae", function() various_textobjs.entireBuffer() end, { desc = "Entire buffer" })
