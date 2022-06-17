-- alias for this file
local o = vim.opt

-- o.nocompatible = true -- this isnt REAL
o.showmatch = true

local function recursive_path()
    -- include subdirectories when searching
    local max = 100 -- maximum number of sub-files to search for
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


o.wildmenu = true

-- buffers can be hidden if modified
o.hidden = true

-- more natural splits
o.splitbelow = true
o.splitright = true

-- spellchecking
o.spellsuggest = "best,3" -- suggest 3 best matches
-- o.spell = true -- enable spell checking
o.spelllang = "en_us,en_gb,cjk"

-- better searching
o.ignorecase = true
o.smartcase = true
o.hlsearch = true -- highlight search targets
o.incsearch = true

-- tabs
o.tabstop = 4
o.softtabstop = 4 -- see 4 spaces as a tab
o.expandtab = true -- convert tabs to whitespace
o.shiftwidth = 4 -- autoident width
o.autoindent = true -- indent newlines to the same as previous lines
cmd("filetype plugin indent on")


-- line numbers and lines
o.number = true
o.relativenumber = true
o.cursorline = true -- highlight line cursor is on
o.cursorlineopt = "both"
-- o.signcolumn = "yes" -- shows signs in the number column
o.numberwidth = 1

-- fonts and colors
o.termguicolors = true -- use 24bit rgb color
o.guifont = "Comic Code,Fira Code Nerd Font Mono,VictorMono Nerd Font:h11"
cmd("hi Comment cterm=italic")
cmd("hi Comment gui=italic")

-- misc
o.cc = "80" -- 80 char width column for coding style
o.clipboard = "unnamedplus" -- system clipboard
o.ttyfast = true -- speeds up scrolling
-- o.scrolloff = 8 -- number of lines to keep above and below cursor
o.showmode = true
o.magic = true -- :h magic
o.emoji = true
-- o.whichwrap:append "<>[]hl" -- :h whichwrap
