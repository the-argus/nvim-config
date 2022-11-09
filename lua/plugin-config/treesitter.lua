local is_okay, configs = pcall(require, 'nvim-treesitter.configs')
if not is_okay then
    return
end

configs.setup {
    -- A list of parser names, or "all"
    ensure_installed = {},

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- List of parsers to ignore installing (for "all")
    -- ignore_install = { },

    highlight = {
        -- `false` will disable the whole extension
        enable = true,

        -- list of language that will be disabled
        -- disable = { "c", "rust" },

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },

    rainbow = {
        enable = true,
        -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
        extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
        max_file_lines = nil, -- Do not enable for files with more than n lines, int
        -- colors = {}, -- table of hex strings
        -- termcolors = {} -- table of colour name strings
    }
}

-- add glsl filetypes
vim.filetype.add({
    pattern = {
        ["*.vs;*.fs"] = "shader",
    }
})

-- add them to treesitter
local ft_to_parser = require "nvim-treesitter.parsers".filetype_to_parsername

ft_to_parser.vs = "glsl"
ft_to_parser.fs = "glsl"
