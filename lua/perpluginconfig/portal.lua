local present = pcall(require, "portal")
if not present then
    return
end

-- portal backward through the jumplist
vim.keymap.set("n", "<Leader>o", "<Cmd>Portal jumplist backward<CR>")
-- portal forward through the jumplist
vim.keymap.set("n", "<Leader>i", "<Cmd>Portal jumplist forward<CR>")
