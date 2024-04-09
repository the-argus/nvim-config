if InNix then
    --Enable (broadcasting) snippet capability for completion
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    return {
        cmd = { "html-languageserver", "--stdio" },
        filetypes = { "html" },
        init_options = {
            configurationSection = { "html", "css", "javascript" },
            embeddedLanguages = {
                css = true,
                javascript = true
            },
            provideFormatter = true
        },
        settings = {},
        single_file_support = true,
        capabilities = capabilities
    }
else
    return {}
end
