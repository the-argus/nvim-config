local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
    return
end

require("plugin-config.lsp.configs")
require("plugin-config.lsp.null-ls")
require("plugin-config.lsp.handlers").setup()

-- allow jdtls to not load until we enter a java file
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = "*.java",
    callback = function()
        require("plugin-config.lsp.java")
    end
})
