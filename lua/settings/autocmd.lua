-- settings.autocmd

local api = vim.api
local line = api.line
local neovim = require "utils.neovim"
local autocmd = neovim.autocmd

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

local function recursive_path()
    -- include subdirectories when searching
    local max = 50 -- maximum number of sub-files to search for
    local c = 0
    for path in string.gmatch(vim.fn.glob("**"), "%S+") do
        vim.opt.path:append(path)
        c = c + 1
        if c >= max then
            break
        end
    end
end

-- autocmd for checking if we're in a git repo
-- stolen from https://github.com/WieeRd/nvim/blob/master/lua/custom/autocmds.lua#L10-L27
local function recursive_path_if_git()
    local cmd = "git rev-parse --is-inside-work-tree"
    if vim.fn.system(cmd) == "true\n" then
        recursive_path()
        return true -- remove autocmd after lazy loading git plugins
    end
end

vim.api.nvim_create_autocmd(
    { "VimEnter", "DirChanged" },
    {
        callback = function() vim.schedule(recursive_path_if_git) end,
        group = vim.api.nvim_create_augroup("CustomAutocmds", { clear = true })
    }
)

-- automatically enter insert mode when opening terminal
vim.api.nvim_create_autocmd(
    { "TermOpen" },
    {
        callback = function() vim.cmd("startinsert") end,
        group = vim.api.nvim_create_augroup("CustomAutocmds", { clear = true })
    }
)
-- remove line numbers from terminal
vim.api.nvim_create_autocmd(
    { "TermOpen" },
    {
        callback = function() vim.cmd("setlocal listchars= nonumber norelativenumber") end,
        group = vim.api.nvim_create_augroup("CustomAutocmds", { clear = true })
    }
)
