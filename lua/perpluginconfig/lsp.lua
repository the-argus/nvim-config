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

local group = vim.api.nvim_create_augroup("UserLspStart", { clear = true })
for name, cfg in pairs(servers) do
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = cfg.filetypes,
        callback = function(args)
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
            vim.lsp.start({
                name = name,
                cmd = cmd,
                root_dir = root,
                settings = cfg.settings,
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
