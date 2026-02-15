local is_okay, treesitter = pcall(require, 'nvim-treesitter')
if not is_okay then
    vim.notify("Failed to load treesitter")
    return
end

treesitter.setup {
    -- not used, installed via nix
    install_dir = vim.fn.stdpath('data') .. '/site',
}

local function start_treesitter_on_buffer()
    local ft = vim.bo.filetype
    local available_parsers = treesitter.get_available()

    if vim.tbl_contains(available_parsers, ft) then
        vim.treesitter.start()
    end
end

vim.api.nvim_create_autocmd("BufRead", {
    pattern = "*",
    callback = start_treesitter_on_buffer,
})

local rainbow_is_okay, rainbow = pcall(require, 'rainbow-delimiters.setup')
if not rainbow_is_okay then
    vim.notify("Failed to load rainbow-delimiters")
    return
end

-- i like the default rainbow config
rainbow.setup {}
