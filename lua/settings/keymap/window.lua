local k = vim.keymap.set

local opts = { silent = true }

-- k("n", "<C-h>", "<Cmd>wincmd h<CR>", opts)
-- k("n", "<C-l>", "<Cmd>wincmd l<CR>", opts)

k("t", "<Esc>", "<C-\\><C-n>", opts)

k("t", "<A-h>", "<C-\\><C-N><C-w>h", opts)
k("t", "<A-j>", "<C-\\><C-N><C-w>j", opts)
k("t", "<A-k>", "<C-\\><C-N><C-w>k", opts)
k("t", "<A-l>", "<C-\\><C-N><C-w>l", opts)
k("i", "<A-h>", "<C-\\><C-N><C-w>h", opts)
k("i", "<A-j>", "<C-\\><C-N><C-w>j", opts)
k("i", "<A-k>", "<C-\\><C-N><C-w>k", opts)
k("i", "<A-l>", "<C-\\><C-N><C-w>l", opts)
k("n", "<A-h>", "<C-w>h", opts)
k("n", "<A-j>", "<C-w>j", opts)
k("n", "<A-k>", "<C-w>k", opts)
k("n", "<A-l>", "<C-w>l", opts)

-- open new window with leader
k("n", "<Leader>l", "<Cmd>vsplit<CR>", opts)
k("n", "<Leader>h", "<Cmd>vsplit<CR><C-w>h", opts)

k("n", "<Leader>j", "<Cmd>split<CR>", opts)
k("n", "<Leader>k", "<Cmd>split<CR><C-w>k", opts)

-- resize window with ctrl
k("n", "<C-h>", "<C-w><", opts)
k("n", "<C-l>", "<C-w>>", opts)
k("n", "<C-k>", "<C-w>+", opts)
k("n", "<C-j>", "<C-w>-", opts)
