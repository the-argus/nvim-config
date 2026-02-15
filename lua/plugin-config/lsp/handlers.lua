local M = {}

-- TODO: backfill this to template
M.setup = function()
    local config = {
        -- disable virtual text
        virtual_text = false,
        -- show signs
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN] = "",
                [vim.diagnostic.severity.HINT] = "",
                [vim.diagnostic.severity.INFO] = "",
            }
        },
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
            focusable = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    }

    vim.diagnostic.config(config)

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
    })

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
    })

    -- workaround from https://github.com/neovim/neovim/issues/30985#issuecomment-2447329525
    for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
        local default_diagnostic_handler = vim.lsp.handlers[method]
        vim.lsp.handlers[method] = function(err, result, context, config)
            if err ~= nil and err.code == -32802 then
                return
            end
            return default_diagnostic_handler(err, result, context, config)
        end
    end
end

local function lsp_highlight_document(client)
    -- Set autocommands conditional on server_capabilities
    if client.server_capabilities.document_highlight then
        vim.api.nvim_exec(
            [[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
            false
        )
    end
end

local lsp_keymap_config = require("settings.keymap.lsp")

M.on_attach = function(client, bufnr)
    -- fix overrides
    -- disable formatting for a lang server
    local disabled_formatting = {
        "nil_ls",
        "html",
        "ts_ls",
        "cssls",
    }
    local is_disabled = function(name)
        for _, value in pairs(disabled_formatting) do -- For all the values/"items" in the list, do this:
            if value == name then
                return true
            end
        end
        return false
    end
    if is_disabled(client.name) then
        client.server_capabilities.document_formatting = false
    end
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    lsp_highlight_document(client)
end

-- this is run for every LSP, used to create keymaps
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        lsp_keymap_config.create_keymaps(args.buf, args)
    end,
})

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
    return
end

M.capabilities = cmp_nvim_lsp.default_capabilities()

return M
