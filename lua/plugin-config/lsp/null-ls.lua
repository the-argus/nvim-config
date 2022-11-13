local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions

local eslint_config = {
    filetypes = {
        -- "html",
        "js",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
    };
    command = "eslint_d";
    args = { "-f",
        "json",
        "--stdin",
        "--stdin-filename",
        "$FILENAME"
    };
}

local spellchecking_settings = {
    filetypes = {
        "tex",
        "text",
        "markdown"
    }
};

local cspell_config = {
    filetypes = {
        "python",
        "javascript",
        "html",
        "css",
        "cpp",
        "c"
    }
}

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
        formatting.rustfmt,

        -- formatting.nixfmt,
        formatting.alejandra,
        code_actions.statix,
        diagnostics.deadnix,

        -- diagnostics.eslint_d.with(eslint_config),
        -- code_actions.eslint_d.with(eslint_config),
        diagnostics.standardjs,
        formatting.standardjs,

        formatting.prettier,


        diagnostics.cspell,
        code_actions.cspell,
        code_actions.proselint.with(spellchecking_settings),

        -- formatting.prettier_d_slim.with({
        --     filetypes = { "css" };
        -- }),
        -- formatting.rome,
        -- formatting.stylelint,
    },
})
