local utils = require("utils.neovim")
local k = vim.keymap.set

k('n', '<S-x>', utils.buffer_close) -- close a buffer
k('n', '<S-k>', '<Cmd>bnext<CR>') -- next buffer
k('n', '<S-j>', '<Cmd>bprevious<CR>') -- previous buffer
k('n', '<Leader>f', '<Cmd>BufferLinePick<CR>') -- pick buffer
