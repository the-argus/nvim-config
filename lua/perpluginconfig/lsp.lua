-- servers need to know what features are supported by completion
local capabilities = nil
local cmp_present, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_present then
    capabilities = cmp_nvim_lsp.default_capabilities()
end

local servers = {
    clangd = {
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
    },
    nil_ls = {
        cmd = { "nil" },
        filetypes = { "nix" },
        root_markers = { "flake.nix", ".git" },
    },
    bashls = {
        cmd = { "bash-language-server", "start" },
        filetypes = { "sh", "bash" },
        root_markers = { ".git" },
        -- different bashls instance which is the same except it doesn't spawn
        -- shellcheck. this is needed because shellcheck will take a really
        -- long time to start and use a bunch of memory and sometimes get
        -- orphaned and just sit around using memory and cpu
        large_file = {
            name = "bashls_no_shellcheck",
            settings = { bashIde = { shellcheckPath = "" } },
        },
    },
    lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    library = {
                        vim.env.VIMRUNTIME .. "/lua",
                        vim.fn.stdpath("config") .. "/lua",
                    },
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    },
    rust_analyzer = {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = { "Cargo.toml", ".git" },
        settings = {
            ["rust-analyzer"] = {
                diagnostics = { experimental = { enable = true } },
                check = {
                    command = "clippy"
                },
            },
        },
    },
    pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
        settings = {
            python = {
                analysis = {
                    diagnosticMode = "workspace", -- "openFilesOnly" is the default
                },
            },
        },
    },
    ts_ls = {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        root_markers = { "package.json", "tsconfig.json", ".git" },
    },
    html = {
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html" },
        root_markers = { ".git" },
    },
    cssls = {
        cmd = { "vscode-css-language-server", "--stdio" },
        filetypes = { "css", "scss", "less" },
        root_markers = { ".git" },
    },
    emmet_ls = {
        cmd = { "emmet-ls", "--stdio" },
        filetypes = { "html", "css", "sass", "scss", "less" },
        root_markers = { ".git" },
    },
    cmake = {
        cmd = { "cmake-language-server" },
        filetypes = { "cmake" },
        root_markers = { "CMakeLists.txt", ".git" },
    },
    zls = {
        cmd = { "zls" },
        filetypes = { "zig", "zir" },
        root_markers = { "build.zig", ".git" },
    },
    nimls = {
        cmd = { "nimlsp" },
        filetypes = { "nim" },
        root_markers = { ".git" },
    },
    slint_lsp = {
        cmd = { "slint-lsp" },
        filetypes = { "slint" },
        root_markers = { ".git" },
    },
    gdscript = {
        cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
        filetypes = { "gd", "gdscript", "gdscript3" },
        root_markers = { "project.godot", ".git" },
    },
    jdtls = {
        cmd = { "jdtls" },
        -- jdtls has to have a temp/cache path for each project
        cmd_fn = function(root)
            local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. root:gsub("[/\\:]", "%%")
            return { "jdtls", "-data", workspace }
        end,
        filetypes = { "java" },
        root_markers = { "gradlew", "mvnw", "pom.xml", "build.gradle", ".git" },
        single_file = true,
    },
}

local large_file_bytes = 100 * 1024

local group = vim.api.nvim_create_augroup("UserLspStart", { clear = true })
for name, cfg in pairs(servers) do
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = cfg.filetypes,
        callback = function(args)
            if not require("perpluginconfig.lsp_state").enabled(args.buf) then
                return
            end
            -- check if server is a command, then check if the first arg is
            -- executable, if not then just cancel starting the LSP instead of
            -- erroring
            if type(cfg.cmd) == "table" and vim.fn.executable(cfg.cmd[1]) == 0 then
                return
            end
            local root = vim.fs.root(args.buf, cfg.root_markers)
            local cmd = cfg.cmd
            if cfg.cmd_fn then
                cmd = cfg.cmd_fn(root)
            end
            local client_name, settings = name, cfg.settings
            local buf_bytes = vim.api.nvim_buf_get_offset(args.buf, vim.api.nvim_buf_line_count(args.buf))
            if cfg.large_file and buf_bytes > large_file_bytes then
                client_name = cfg.large_file.name
                settings = cfg.large_file.settings
            end
            vim.lsp.start({
                name = client_name,
                cmd = cmd,
                root_dir = root,
                settings = settings,
                capabilities = capabilities,
            }, { bufnr = args.buf })
        end,
    })
end

-- in old versions of neovim (pre 0.10.3) and newer versions of rust-analyzer
-- would spam errors when you typed, I guess due to not being able to serve all
-- the requests. This is a workaround for that from:
-- https://github.com/neovim/neovim/issues/30985#issuecomment-2447329525
for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end

--- Detach all clients from a given buffer
local function detach_all(buf)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
        vim.lsp.buf_detach_client(buf, client.id)
    end
    -- remove all diagnostics under all namespaces and then also disable
    -- diagnostics altogether
    vim.diagnostic.reset(nil, buf)
    vim.diagnostic.enable(false, { bufnr = buf })
end

---@param filetype string
---@return string[]
local function get_all_lsp_client_names_for_filetype(filetype)
    local client_names = { "null-ls" }
    for server_name, server_config in pairs(servers) do
        if vim.tbl_contains(server_config.filetypes, filetype) then
            table.insert(client_names, server_name)
            if server_config.large_file then
                table.insert(client_names, server_config.large_file.name)
            end
        end
    end
    return client_names
end

---@param buf integer
local function restart_all_clients_for_buffer(buf)
    local client_names = get_all_lsp_client_names_for_filetype(vim.bo[buf].filetype)
    local clients_to_stop = vim.tbl_filter(function(client)
        return vim.tbl_contains(client_names, client.name)
    end, vim.lsp.get_clients())

    local buffers_to_reattach = { [buf] = true }
    for _, client in ipairs(clients_to_stop) do
        for attached_buffer in pairs(client.attached_buffers) do
            buffers_to_reattach[attached_buffer] = true
        end
        client:stop()
    end

    local force_stop_after_milliseconds = 2000
    local give_up_after_milliseconds = 5000
    local poll_interval_milliseconds = 50
    local elapsed_milliseconds = 0
    local function start_clients_once_all_stopped()
        local all_stopped = vim.iter(clients_to_stop):all(function(client)
            return client:is_stopped()
        end)
        if not all_stopped and elapsed_milliseconds < give_up_after_milliseconds then
            if elapsed_milliseconds >= force_stop_after_milliseconds then
                for _, client in ipairs(clients_to_stop) do
                    client:stop(true)
                end
            end
            elapsed_milliseconds = elapsed_milliseconds + poll_interval_milliseconds
            vim.defer_fn(start_clients_once_all_stopped, poll_interval_milliseconds)
            return
        end
        for buffer_to_reattach in pairs(buffers_to_reattach) do
            if vim.api.nvim_buf_is_valid(buffer_to_reattach) then
                -- rerun filetype / attach autocommands
                vim.api.nvim_exec_autocmds("FileType", { buffer = buffer_to_reattach })
            end
        end
    end
    start_clients_once_all_stopped()
end

-- Set if LSP is enabled on a given buffer true/false
---@param buf integer
---@param enabled boolean
local function set_lsp_enabled(buf, enabled)
    vim.b[buf].lsp_enabled = enabled
    if enabled then
        -- reset diagnostics as well
        vim.diagnostic.reset(nil, buf)
        vim.diagnostic.enable(true, { bufnr = buf })
        restart_all_clients_for_buffer(buf)
    else
        detach_all(buf)
    end
end

local lsp_state = require("perpluginconfig.lsp_state")

vim.api.nvim_create_user_command("LspToggle", function()
    local buf = vim.api.nvim_get_current_buf()
    local enabled = not lsp_state.enabled(buf)
    set_lsp_enabled(buf, enabled)
    vim.notify("LSP " .. (enabled and "enabled" or "disabled") .. " for this buffer")
end, { desc = "Toggle language servers for the current buffer" })

vim.api.nvim_create_user_command("LspEnable", function()
    set_lsp_enabled(vim.api.nvim_get_current_buf(), true)
end, { desc = "Attach language servers to the current buffer" })

vim.api.nvim_create_user_command("LspDisable", function()
    set_lsp_enabled(vim.api.nvim_get_current_buf(), false)
end, { desc = "Detach language servers from the current buffer" })

vim.keymap.set("n", "<Leader>l", "<Cmd>LspToggle<CR>",
    { desc = "Toggle LSP for this buffer", silent = true })
