local k = vim.keymap.set

local opts = { silent = true }

k('n', '<Leader>e', "<Cmd>NvimTreeOpen<CR>", opts)
k('n', '<Leader>f', "<Cmd>NvimTreeClose<CR>", opts)
