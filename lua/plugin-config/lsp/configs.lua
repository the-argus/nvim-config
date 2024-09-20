local lspconfig = require("lspconfig")
local minimal_servers = {
    "clangd",
    "nil_ls",
    "bashls"
}
local servers = {
    -- NOTE: jdtls unused because using dedicated nvim-jdtls plugin
    -- "jdtls",
    "lua_ls",
    "rust_analyzer",
    "pyright",
    "html",
    "cssls",
    "tsserver",
    -- "ansiblels",
    "emmet_ls",
    "nimls",
    "cmake",
    "zls",
    "gdscript",
    -- "qmlls",
    "slint_lsp",
    unpack(minimal_servers),
    "omnisharp"

    -- using standardjs in null-ls instead of these
    -- "quick_lint_js",
    -- "eslint",

    -- using markdownlint in null-ls instead of this
    -- "lemminx",
}

local s = servers
if Minimal then
    s = minimal_servers
end

-- LSP installer stuff if not using nix to manage LSPs
if not InNix then
    local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
    if not status_ok then
        return
    end
    local install_path = vim.fn.stdpath("data") .. "/lsp_servers"
    lsp_installer.setup {
        ensure_installed = s,

        automatic_installation = true,
        -- The directory in which to install all servers.
        install_root_dir = install_path
    }
end

for _, server in pairs(s) do
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
