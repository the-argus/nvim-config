local k = vim.keymap.set

local opts = { silent = true }

k('n', '<C-h>', "<Cmd>wincmd h<CR>", opts)
k('n', '<C-l>', "<Cmd>wincmd l<CR>", opts)
