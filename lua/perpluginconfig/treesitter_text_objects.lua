local textobjects_ok, textobjects = pcall(require, "nvim-treesitter-textobjects")
if not textobjects_ok then
    return
end

textobjects.setup {
    select = {
        -- Automatically jump forward to textobj
        lookahead = true,
        -- options are ('v', 'V', or '<c-v>') for charwise, linewise, and blockwise respectively
        selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@parameter.inner'] = 'v',
            ['@function.outer'] = 'V',
            ['@function.inner'] = 'v',
            ['@class.outer'] = 'V',
            ['@class.inner'] = 'v',
        },
    },
    move = {
        -- whether to set jumps in the jumplist
        set_jumps = true,
    },
}

-- keymaps
-- You can use the capture groups defined in `textobjects.scm`
vim.keymap.set({ "x", "o" }, "am", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "im", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ar", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ir", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
end)
-- ia and aa are handled by mini.ai

-- allow swapping parameters up and down. not including classes or functions because `dif` followed by `[f` and then a paste seems sufficient
vim.keymap.set("n", "<leader>a", function()
    require("nvim-treesitter-textobjects.swap").swap_next "@parameter.inner"
end)
vim.keymap.set("n", "<leader>A", function()
    require("nvim-treesitter-textobjects.swap").swap_previous "@parameter.outer"
end)

-- open and close bracket motions for going to the end or start of things, whichever is closer
vim.keymap.set({ "n", "x", "o" }, "]m", function()
    require("nvim-treesitter-textobjects.move").goto_next("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[m", function()
    require("nvim-treesitter-textobjects.move").goto_previous("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]r", function()
    require("nvim-treesitter-textobjects.move").goto_next("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[r", function()
    require("nvim-treesitter-textobjects.move").goto_previous("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]a", function()
    require("nvim-treesitter-textobjects.move").goto_next("@parameter.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[a", function()
    require("nvim-treesitter-textobjects.move").goto_previous("@parameter.outer", "textobjects")
end)
