local k = vim.keymap.set

k('n', '<Leader>t', '<Cmd>enew<CR>') -- open a new empty buffer
k('n', '<Leader>x', '<Cmd>bp<bar>sp<bar>bn<bar>bd<CR>') -- close a buffer
k('n', '<S-k>', '<Cmd>bnext<CR>') -- next buffer
k('n', '<S-j>', '<Cmd>bprevious<CR>') -- previous buffer

