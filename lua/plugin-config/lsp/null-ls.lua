local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
    debug = false,
    sources = {
        formatting.black.with({ extra_args = { "--fast" } }),
        -- formatting.stylua,
        -- diagnostics.flake8,
        diagnostics.markdownlint,
        formatting.markdownlint,
        diagnostics.jsonlint,
        formatting.fixjson,

        -- formatting.nixfmt,
        formatting.alejandra,
	-- diagnostics.deadlint, -- cool but not packaged for nix, ill do that later
        formatting.rustfmt,

	diagnostics.eslint_d,
        formatting.prettier_d_slim.with({
            filetypes = { "javascript",
	    		  "javascriptreact",
			  "typescript",
			  "typescriptreact",
			  "vue",
			  "css",
			  "scss",
			  "less",
			  "html",
			  "json",
			  "jsonc",
			  "yaml",
			  "markdown",
			  "markdown.mdx",
			  "graphql",
			  "handlebars"
	    };
        }),
        -- formatting.prettier_d_slim.with({
        --     filetypes = { "css" };
        -- }),
        -- formatting.rome,
        -- formatting.stylelint,
    },
})
