local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

require("plugin-config.lsp.lsp-installer")
require("plugin-config.lsp.handlers").setup()
