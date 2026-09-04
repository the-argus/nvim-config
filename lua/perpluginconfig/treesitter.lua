-- register and start a treesitter parser whenever a matching buffer is loaded
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})
