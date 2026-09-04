local lsp_lines_ok, lsp_lines = pcall(require, "lsp_lines")
if not lsp_lines_ok then
    return
end

-- supposedly neovim virtual text is redundant with lsp_lines
vim.diagnostic.config({
    virtual_text = false,
})

lsp_lines.setup()

vim.api.nvim_create_user_command("ToggleLSPLines", lsp_lines.toggle, {})
