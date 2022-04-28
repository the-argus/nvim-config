-- settings.autocmd

local api = vim.api
local line = api.line
local neovim = require "utils.neovim"
local autocmd = neovim.autocmd

-- keymasters recompiliation autocmd
autocmd("BufWritePost", function()
  require("packer").compile()
end, {
  patterns = "*/lua/plugins/*.lua",
  desc = "Automatically re-compile plugin specifications on changing the matched pattern files.",
})

autocmd("TextYankPost", function()
  vim.highlight.on_yank {
    higroup = "YankFeed",
    on_macro = true,
    on_visual = true,
    timeout = 150,
  }
end, { desc = "Provide a visual color feedback on yanking." })

-- remember cursor position
-- idk how to write this in lua...
vim.cmd([[
augroup vimStartup
    au!
    autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif
augroup END
]])
