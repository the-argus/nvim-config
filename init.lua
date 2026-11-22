-- number column should use relativenumber except for the current line
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 2 -- thin number column

-- highlight current line and the line number
vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"

vim.opt.wrap = true

-- keep a buffer of 10 characters above cursor and 8 characters to the side of
-- the cursor (the latter only applies when wrapping is off so horizontal
-- scrolling can occur)
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- 4 space width for tabs, always use tabs, try to retain indent when going to
-- the next line
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = false -- tabs
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true
vim.opt.showbreak = ""

-- buffer search should be case insensitive unless the search pattern includes
-- a capital letter, and should update search results live while typing
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true -- <Leader>c will clear highlights
vim.opt.incsearch = true

-- spell checking (these only come into play if I do :set spell to enable them)
vim.opt.spellsuggest = "best,3"       -- Suggest 3 best matches
vim.opt.spelllang = "en_us,en_gb,cjk" -- Don't flag CJK characters as errors

-- visuals
vim.opt.termguicolors = true -- 24-bit colors
vim.opt.signcolumn = "yes"   -- always show sign column

-- GUI settings (terminals and neovide)
vim.opt.guifont = "Comic Code,Fira Code Nerd Font Mono,VictorMono Nerd Font:h11"
vim.g.neovide_cursor_animation_length = 0.13
vim.g.neovide_cursor_trail_length = 0.8
vim.g.neovide_cursor_vfx_mode = "railgun"
vim.g.neovide_input_macos_option_key_is_meta = "both" -- make <A-hjkl> work on macos with neovide

-- make everything after 80 chars a different color
local columnRange = {}
for i = 81, 999 do
    table.insert(columnRange, i)
end
vim.opt.cc = columnRange
vim.opt.showmatch = true -- highlight matching brackets
vim.opt.matchtime = 9999 -- how long to show matching bracket
vim.opt.cmdheight = 1    -- command line height
vim.opt.pumheight = 10   -- pum height == popup menu height
-- vim.opt.pumblend = 10      -- popup menu transparency
vim.opt.winblend = 0     -- floating window transparency

-- disable the conceal feature to replace TeX, markdown, etc. with nice
-- characters, because I want to be editing the characters
vim.opt.conceallevel = 0
vim.opt.concealcursor = "" -- don't hide cursor line markup

-- remember undo/redo after closing a buffer
local undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.undofile = true
vim.opt.undodir = undodir

-- responsiveness
vim.opt.updatetime = 300 -- fast completion TODO: does this matter with my cmp settings?
vim.opt.timeoutlen = 500 -- key timeout duration
vim.opt.ttimeoutlen = 0  -- key code timeout

-- automatically reload files when they are changed and never automatically save
vim.opt.autoread = true
vim.opt.autowrite = false

-- misc settings
vim.opt.hidden = true                   -- allow hidden buffers
vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"  -- allow backspacing over indents, newlines, and start of insert
vim.opt.autochdir = false               -- don't auto change directory to buffer location
vim.opt.iskeyword:remove("/")           -- consider / to be a break in words
vim.opt.path:append("**")               -- include subdirectories in search
vim.opt.selection = "inclusive"         -- include last character in selection in copy
vim.opt.mouse = "a"                     -- enable mouse support
vim.opt.clipboard:append("unnamedplus") -- use system clipboard
vim.opt.modifiable = true               -- allow buffer modifications TODO: is this needed
vim.opt.encoding = "UTF-8"

-- use hyphen as part of identifier only in languages where that makes sense,
-- otherwise in C and C++ things like a pointer dereference will get included
-- in the word textobject
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "css", "scss", "less", "html", "lisp", "clojure", "scheme", "racket", "fennel", "nix" },
    callback = function() vim.opt_local.iskeyword:append("-") end,
})

-- may have installed LSPs and tooling in local node modules
vim.env.PATH = vim.env.PATH .. ":./node_modules/.bin"

-- neovim doesn't support slint by default
vim.filetype.add({ extension = { slint = "slint" } })

-- I use telescope, I have no clue why but for some reason there is this
-- fzf plugin that also gets added? TODO: figure out why this is happening
vim.g.loaded_fzf = 1

-- Make cursor blink nicely
vim.o.guicursor = table.concat({
    "n-v-c:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100",
    "i-ci:ver25-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100",
    "r:hor50-Cursor/lCursor-blinkwait100-blinkon100-blinkoff100"
}, ",")

-- split behavior
vim.opt.splitbelow = true -- horizontal splits go below
vim.opt.splitright = true -- vertical splits go right

-- key mappings
vim.g.mapleader = " "
vim.g.maplocalleader = " " -- TODO: what is local leader

-- normal mode mappings
vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- center screen when jumping to next match
-- TODO: make this work for C-p and C-n, maybe the next/prev diagnostic/hunk/function etc as well?
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set({ "n", "x" }, "<C-n>", "n", { remap = true, desc = "Next search result" })
vim.keymap.set({ "n", "x" }, "<C-p>", "N", { remap = true, desc = "Previous search result" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

local function noscroll_jump_cursor_by_half_page(direction)
    return function()
        local scrolloff = vim.wo.scrolloff >= 0 and vim.wo.scrolloff or vim.go.scrolloff
        local top_line, bottom_line, last_line = vim.fn.line("w0"), vim.fn.line("w$"), vim.fn.line("$")
        local min = top_line == 1 and 1 or math.min(top_line + scrolloff, bottom_line)
        local max = bottom_line == last_line and last_line or math.max(bottom_line - scrolloff, min)
        local current_line = vim.fn.line(".")
        local target_line = current_line + direction * vim.v.count1 * vim.wo.scroll
        target_line = math.max(min, math.min(max, target_line))
        if (target_line - current_line) * direction > 0 then
            vim.cmd("keepjumps normal! " .. target_line .. "G")
        end
    end
end

vim.keymap.set({ "n", "x" }, "<C-j>", noscroll_jump_cursor_by_half_page(1),
    { desc = "Move cursor by half a page down without scrolling the view" })
vim.keymap.set({ "n", "x" }, "<C-k>", noscroll_jump_cursor_by_half_page(-1),
    { desc = "Move cursor by half a page up without scrolling the view" })

-- delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- buffer navigation
local function buffer_close()
    vim.cmd(":bp|sp|bn|bd")
end
vim.keymap.set('n', '<S-x>', buffer_close)
vim.keymap.set('n', '<S-k>', '<Cmd>bnext<CR>')
vim.keymap.set('n', '<S-j>', '<Cmd>bprevious<CR>')

-- exit terminal mode with escape, I always forget this keybind
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true })

-- custom window resizing mode activated by <Leader>w where hjkl resizes the active buffer, Esc to exit
local resize_wincmd_by_key = { h = "<", l = ">", k = "+", j = "-" }
vim.keymap.set("n", "<Leader>w", function()
    while true do
        vim.api.nvim_echo({ { "-- RESIZE --", "ModeMsg" } }, false, {})
        vim.cmd.redraw()
        local key = vim.fn.getcharstr()
        local resize_wincmd = resize_wincmd_by_key[key]
        if resize_wincmd == nil then
            vim.api.nvim_echo({ { "" } }, false, {})
            if key ~= vim.keycode("<Esc>") then
                vim.api.nvim_feedkeys(key, "m", false)
            end
            return
        end
        vim.cmd.wincmd(resize_wincmd)
    end
end, { desc = "Window resizing mode, use hjkl" })

-- copy file path to current buffer
vim.keymap.set("n", "<leader>pa", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    print("file:", path)
end)

-- keep a ring buffer of recently pressed keys to help debug when weird stuff
-- happens
local keylog = {}
local keylog_max = 100

vim.on_key(function(_, typed)
    if typed == "" then
        return
    end
    keylog[#keylog + 1] = {
        key = vim.fn.keytrans(typed),
        mode = vim.api.nvim_get_mode().mode,
        at = vim.uv.hrtime(),
    }
    if #keylog > keylog_max then
        table.remove(keylog, 1)
    end
end)

-- :KeyLog usercommand to observe the most recently pressed keys, for debugging
vim.api.nvim_create_user_command("KeyLog", function(args)
    local last = #keylog
    while last > 0 and keylog[last].mode == "c" do
        last = last - 1
    end
    if last < #keylog and last > 0 then
        last = last - 1
    end

    local count = math.min(tonumber(args.args) or 25, last)
    if count == 0 then
        vim.api.nvim_echo({ { "no keys recorded yet" } }, false, {})
        return
    end
    local chunks = {}
    for i = last - count + 1, last do
        local entry = keylog[i]
        local previous = keylog[i - 1]
        local gap = previous and (entry.at - previous.at) / 1e6 or 0
        table.insert(chunks, { string.format("%-12s", entry.key), "Special" })
        table.insert(chunks, { string.format("mode=%-4s %7.1fms\n", entry.mode, gap) })
    end
    vim.api.nvim_echo(chunks, false, {})
end, { nargs = "?", desc = "Show the last 100 keys pressed" })

-- basic autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- do a highlight effect to indicate yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- auto-close terminal when process exits
vim.api.nvim_create_autocmd("TermClose", {
    group = augroup,
    callback = function()
        if vim.v.event.status == 0 then
            vim.api.nvim_buf_delete(0, {})
        end
    end,
})

-- disable line numbers in terminal and start in insert mode
vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.cmd.startinsert()
    end,
})

-- LSP keymaps and commands, only on buffers with an attached server
vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local keymap_opts = { buffer = args.buf, silent = true }

        if client and client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_buf_create_user_command(args.buf, "Format", function()
                vim.lsp.buf.format({ async = true })
            end, {})
            vim.keymap.set("n", "<Leader>u", "<Cmd>Format<CR>",
                vim.tbl_extend("force", keymap_opts, { desc = "Format the current buffer" }))
        end
        if client and client.server_capabilities.codeActionProvider then
            -- code actions are charwise, ie. you only get ones under the
            -- cursor, but I want all the actions on the current line
            vim.api.nvim_buf_create_user_command(args.buf, "Action", function()
                local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
                local cursor_line_text = vim.api.nvim_get_current_line()
                vim.lsp.buf.code_action({
                    range = {
                        start = { cursor_row, 0 },
                        ["end"] = { cursor_row, math.max(#cursor_line_text - 1, 0) },
                    },
                })
            end, {})
            -- override default action keybind with custom Action usercmd
            vim.keymap.set("n", "gra", "<Cmd>Action<CR>",
                vim.tbl_extend("force", keymap_opts, { desc = "Show all code actions on current line" }))
        end

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, keymap_opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, keymap_opts)
        vim.keymap.set("n", "gh", vim.lsp.buf.hover, keymap_opts)
    end,
})

-- i like the default lsp keymap but it wasn't default in older versions
if vim.fn.has("nvim-0.11") == 0 then
    vim.keymap.set("n", "grn", vim.lsp.buf.rename, { desc = "vim.lsp.buf.rename()" })
    vim.keymap.set("x", "gra", vim.lsp.buf.code_action, { desc = "vim.lsp.buf.code_action()" })
    vim.keymap.set("n", "grr", vim.lsp.buf.references, { desc = "vim.lsp.buf.references()" })
    vim.keymap.set("n", "gri", vim.lsp.buf.implementation, { desc = "vim.lsp.buf.implementation()" })
    vim.keymap.set("n", "gO", vim.lsp.buf.document_symbol, { desc = "vim.lsp.buf.document_symbol()" })
    vim.keymap.set({ "i", "n" }, "<C-s>", vim.lsp.buf.signature_help, { desc = "vim.lsp.buf.signature_help()" })
end
if vim.fn.has("nvim-0.11.2") == 0 then
    vim.keymap.set("n", "grt", vim.lsp.buf.type_definition, { desc = "vim.lsp.buf.type_definition()" })
end

vim.diagnostic.config({
    -- enable virtual lines (or in old versions, virtual text at the end of the line) for diagnostics. alternative to lsp diagnostic float
    -- virtual_lines = vim.fn.has("nvim-0.11") == 1,
    -- virtual_text = vim.fn.has("nvim-0.11") == 0,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
        },
    },
    update_in_insert = true,
    severity_sort = true,
    float = {
        border = "solid",
        focusable = false,
        style = "minimal",
        source = true,
        header = "",
        prefix = "",
    },
    jump = vim.fn.has("nvim-0.12") == 1 and {
        on_jump = function(_, bufnr)
            vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
        end,
    } or { float = true },
})

-- This is the only lsp keybind that isn't created on LspAttach, to include vim
-- itself or none-ls giving diagnostics, in addition to the lsp implementation
-- Default keybind is <C-w>d
vim.keymap.set("n", "gl", function()
    vim.diagnostic.open_float({ scope = "line" })
end, { desc = "Show diagnostics for the current line in a floating window" })

-- solid borders on LSP hover/signature floats as well
if vim.fn.has("nvim-0.11") == 1 then
    vim.o.winborder = "solid" -- default border for all floating windows
else
    -- vim.lsp.with was deprecated and removed after 0.11
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "solid",
    })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "solid",
    })
end

-- auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    callback = function()
        local dir = vim.fn.expand('<afile>:p:h')
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, 'p')
        end
    end,
})

-- disable in favor of cmp's completion popup in the statusbar for commands
-- TODO: tab will still autocomplete, although the wildmenu is invisible. figure
-- out a way to disable tab here
vim.opt.wildmenu = false
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- better diff options
vim.opt.diffopt:append("linematch:60")

-- performance improvements
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000
vim.opt.lazyredraw = true -- don't redraw during macros

-- create undo directory if it doesn't exist
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end

-- load and configure plugins
require "perpluginconfig"
require "textobjects"

-- shorthand for ]w and other square bracket keybinds that just go to the next thing previous thing
for _, keymap in ipairs(vim.api.nvim_get_keymap("n")) do
    local letter = keymap.lhs:match("^%]([a-z])$")
    if letter then
        vim.keymap.set({ "n", "o" }, "<M-" .. letter .. ">", "]" .. letter,
            { remap = true, desc = "Same as ]" .. letter })
        vim.keymap.set({ "n", "o" }, "<M-" .. letter:upper() .. ">", "[" .. letter,
            { remap = true, desc = "Same as [" .. letter })
    end
end
