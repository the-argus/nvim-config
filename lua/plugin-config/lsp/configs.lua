local lspconfig = require("lspconfig")
local servers = {
    "clangd",
    "rnix",
    "sumneko_lua",
    "pyright",
    "html",
    "cssls",
    "bashls",
    "ansiblels",
    "emmet_ls",
    "rust_analyzer"

    -- using standardjs in null-ls instead of these
    -- "quick_lint_js",
    -- "eslint",

    -- using markdownlint in null-ls instead of this
    -- "lemminx",

    -- csharp SUCKS
    -- "omnisharp",
    -- "csharp_ls",
}

-- LSP installer stuff if not using nix to manage LSPs
if not InNix then
    local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
    if not status_ok then
        return
    end
    local install_path = vim.fn.stdpath("data") .. "/lsp_servers"
    lsp_installer.setup {
        ensure_installed = servers,

        automatic_installation = false,
        -- The directory in which to install all servers.
        install_root_dir = install_path
    }
end

for _, server in pairs(servers) do
    local opts = {
        on_attach = require("plugin-config.lsp.handlers").on_attach,
        capabilities = require("plugin-config.lsp.handlers").capabilities,
    }
    local has_custom_opts, server_custom_opts = pcall(require, "plugin-config.lsp.settings." .. server)
    if has_custom_opts then
        opts = vim.tbl_deep_extend("force", server_custom_opts, opts)
    end
    lspconfig[server].setup(opts)
end
