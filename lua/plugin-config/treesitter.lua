local is_okay, configs = pcall(require, 'nvim-treesitter.configs')
if not is_okay then
    return
end


configs.setup {
  -- A list of parser names, or "all"
  ensure_installed = {
        "c", "cpp", "rust",
        "c_sharp", "java", -- cringe
        "bash", "python", "lua",
        "html", "css", "json",
        "glsl", "make",
        -- "markdown" -- not currently supported
        "rasi", "regex", "scss"
    },

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
}

-- add glsl filetypes
vim.filetype.add({
    pattern = {
        ["*.vs;*.fs"] = "shader",
    }
})

-- add them to treesitter
local ft_to_parser = require"nvim-treesitter.parsers".filetype_to_parsername

ft_to_parser.vs = "glsl"
ft_to_parser.fs = "glsl"
