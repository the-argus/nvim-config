local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

if not InNix then
    require("plugin-config.lsp.configs")
end
require("plugin-config.lsp.null-ls")
require("plugin-config.lsp.handlers").setup()
