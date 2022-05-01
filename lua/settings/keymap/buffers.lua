
local utils = require("utils.neovim")
local k = vim.keymap.set

k('n', '<Leader>t', '<Cmd>enew<CR>') -- open a new empty buffer
k('n', '<S-x>', utils.buffer_close) -- close a buffer
k('n', '<S-k>', '<Cmd>bnext<CR>') -- next buffer
k('n', '<S-j>', '<Cmd>bprevious<CR>') -- previous buffer

k('n', '<Leader>1', '<Cmd>BufferLineGoToBuffer 1<CR>')
k('n', '<Leader>2', '<Cmd>BufferLineGoToBuffer 2<CR>')
k('n', '<Leader>3', '<Cmd>BufferLineGoToBuffer 3<CR>')
k('n', '<Leader>4', '<Cmd>BufferLineGoToBuffer 4<CR>')
k('n', '<Leader>5', '<Cmd>BufferLineGoToBuffer 5<CR>')
k('n', '<Leader>6', '<Cmd>BufferLineGoToBuffer 6<CR>')
k('n', '<Leader>7', '<Cmd>BufferLineGoToBuffer 7<CR>')
k('n', '<Leader>8', '<Cmd>BufferLineGoToBuffer 8<CR>')
k('n', '<Leader>9', '<Cmd>BufferLineGoToBuffer 9<CR>')
