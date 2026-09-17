-- null-ls is an adapter for writing analyzers in lua or invoking things that
-- are not LSP implementations as if they were LSPs (spell checkers, static
-- analyzers, etc)
local present, null_ls = pcall(require, "null-ls")
if not present then
    return
end

local spellchecking_settings = {
    filetypes = {
        "tex",
        "text",
        "markdown"
    }
}

local sources = {}

local function add(kind, builtin_name, command, with_opts)
    local builtin = null_ls.builtins[kind][builtin_name]
    -- skip registering the source if the executable is not in PATH
    -- unlike lsp.lua, this happens at editor startup, instead of whenever
    -- a matching filetype is opened
    if builtin == nil or vim.fn.executable(command) == 0 then
        return
    end
    if with_opts then
        builtin = builtin.with(with_opts)
    end
    table.insert(sources, builtin)
end

add("formatting", "black", "black", { extra_args = { "--fast" } })
add("diagnostics", "markdownlint", "markdownlint")
add("formatting", "markdownlint", "markdownlint")
add("diagnostics", "yamllint", "yamllint")
add("formatting", "alejandra", "alejandra")
add("code_actions", "statix", "statix")
add("diagnostics", "deadnix", "deadnix")
add("formatting", "prettier", "prettier")
add("code_actions", "proselint", "proselint", spellchecking_settings)

local lsp_state = require("perpluginconfig.lsp_state")

null_ls.setup({
    debug = false,
    sources = sources,
    -- share state that determines whether to attach our services with regular
    -- LSP. so toggling lsp in a buffer with ToggleLSP affects nonels
    should_attach = function(bufnr)
        return lsp_state.enabled(bufnr)
    end,
})
