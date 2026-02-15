local is_okay, treesitter = pcall(require, 'nvim-treesitter')
if not is_okay then
    vim.notify("Failed to load treesitter")
    return
end

treesitter.setup {
    -- not used, installed via nix
    install_dir = vim.fn.stdpath('data') .. '/site',
}

local minimal_allowed_filetypes = {
    "yaml",
    "toml",
    "regex",
    "python",
    "nix",
    "markdown",
    "make",
    "json",
    "dockerfile",
    "comment",
    "cmake",
    "c",
    "cpp",
    "bash",
}

local extra_allowed_filetypes = {
    "godot_resource",
    "gdscript",
    "gdshader",
    "rust",
    "scss",
    "lua",
    "css",
    "javascript",
    "java",
    "glsl",
    "c_sharp",
    "norg",
    "zig",
    "tsx",
    "zsh",
    "wgsl",
    "vim",
    "typescript",
    "strace",
    "slint",
    "qmljs",
    "qmldir",
    "printf",
    "odin",
    "meson",
    "go",
    "gitignore",
    "gitcommit",
    "git_rebase",
    "bitbake",
};

-- Source - https://stackoverflow.com/a/33511182
-- Posted by Oka, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-02-15, License - CC BY-SA 3.0
local function has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function start_treesitter_on_buffer()
    local ft = vim.bo.filetype

    local available_parsers = minimal_allowed_filetypes
    if not Minimal then
        for _, value in ipairs(extra_allowed_filetypes) do
            table.insert(available_parsers, value)
        end
    end

    if has_value(available_parsers, ft) then
        vim.treesitter.start()
    end
end

vim.api.nvim_create_autocmd("BufRead", {
    pattern = "*",
    callback = start_treesitter_on_buffer,
})

local rainbow_is_okay, rainbow = pcall(require, 'rainbow-delimiters.setup')
if not rainbow_is_okay then
    vim.notify("Failed to load rainbow-delimiters")
    return
end

-- i like the default rainbow config
rainbow.setup {}
