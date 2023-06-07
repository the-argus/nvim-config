return {
    cmd       = { "rust-analyzer" },
    filetypes = { "rust" },
    settings  = {
        ["rust-analyzer"] = {
            diagnostics = { experimental = { enable = true } },
            check = {
                command = "clippy"
            }
        }
    }
}
