-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 2        -- Minimal number column width
vim.opt.cursorline = true      -- Highlight current line
vim.opt.cursorlineopt = "both" -- Highlight both line and number
vim.opt.wrap = true            -- Wrap long lines instead of running them off screen
vim.opt.breakindent = true     -- Continuation lines keep the indent of the line they wrap
vim.opt.showbreak = "↳ "       -- Mark continuation lines so wraps aren't mistaken for real lines
vim.opt.scrolloff = 10         -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8      -- Keep 8 columns left/right of cursor (only matters if wrap is off)

-- Indentation
vim.opt.tabstop = 4        -- Tab width
vim.opt.shiftwidth = 4     -- Indent width
vim.opt.softtabstop = 4    -- Soft tab stop
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true  -- Copy indent from current line

-- Search settings
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true  -- Case sensitive if uppercase in search
vim.opt.hlsearch = true   -- Highlight search results, use <leader>c to clear
vim.opt.incsearch = true  -- Show matches as you type

-- Spelling (these only come into play if I do :set spell to enable spell checking)
vim.opt.spellsuggest = "best,3"       -- Suggest 3 best matches
vim.opt.spelllang = "en_us,en_gb,cjk" -- Don't flag CJK characters as errors

-- Visual settings
-- vim.cmd.colorscheme("retrobox") -- gruvbox, dim comments
-- vim.cmd.colorscheme("sorbet") -- looks like the joker wrote code, bright comments
-- vim.cmd.colorscheme("lunaperche") -- decent, bright comments
-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.opt.termguicolors = true -- Enable 24-bit colors
vim.opt.signcolumn = "yes"   -- Always show sign column

-- GUI settings (neovide etc.)
vim.opt.guifont = "Comic Code,Fira Code Nerd Font Mono,VictorMono Nerd Font:h11"
vim.g.neovide_cursor_animation_length = 0.13
vim.g.neovide_cursor_trail_length = 0.8
vim.g.neovide_cursor_vfx_mode = "railgun"
vim.g.neovide_input_macos_option_key_is_meta = "both" -- make <A-hjkl> work on macos
local columnRange = {}                                -- make everything after 80 chars a different color
for i = 81, 999 do
    table.insert(columnRange, i)
end
vim.opt.cc = columnRange
vim.opt.showmatch = true -- Highlight matching brackets
vim.opt.matchtime = 9999 -- How long to show matching bracket
vim.opt.cmdheight = 1    -- Command line height
-- https://neovim.io/doc/user/options.html#'completeopt'
-- vim.opt.completeopt = "fuzzy,menuone,noselect,popup" -- not available in 0.9
vim.opt.pumheight = 10     -- Popup menu height
-- vim.opt.pumblend = 10      -- Popup menu transparency
vim.opt.winblend = 0       -- Floating window transparency
vim.opt.conceallevel = 0   -- Don't hide markup
vim.opt.concealcursor = "" -- Don't hide cursor line markup
vim.opt.lazyredraw = true  -- Don't redraw during macros
-- vim.opt.synmaxcol = 300    -- Syntax highlighting limit

-- File handling
vim.opt.undofile = true                           -- Persistent undo
vim.opt.undodir = vim.fn.expand("~/.vim/undodir") -- Undo directory
vim.opt.updatetime = 300                          -- Faster completion
vim.opt.timeoutlen = 500                          -- Key timeout duration
vim.opt.ttimeoutlen = 0                           -- Key code timeout
vim.opt.autoread = true                           -- Auto reload files changed outside vim
vim.opt.autowrite = false                         -- Don't auto save

-- Behavior settings
vim.opt.hidden = true                   -- Allow hidden buffers
vim.opt.errorbells = false              -- No error bells
vim.opt.backspace = "indent,eol,start"  -- Allow backspacing over indents, newlines, and start of insert
vim.opt.autochdir = false               -- Don't auto change directory
vim.opt.iskeyword:append("-")           -- Treat dash as part of word
vim.opt.iskeyword:remove("/")           -- Consider / to be a break in words
vim.opt.path:append("**")               -- Include subdirectories in search
vim.opt.selection = "inclusive"         -- Include last character in selection in copy
vim.opt.mouse = "a"                     -- Enable mouse support
vim.opt.clipboard:append("unnamedplus") -- Use system clipboard
vim.opt.modifiable = true               -- Allow buffer modifications
vim.opt.encoding = "UTF-8"              -- Set encoding

-- may have installed LSPs and tooling in local node modules
vim.env.PATH = vim.env.PATH .. ":./node_modules/.bin"

-- neovim doesn't support slint by default
vim.filetype.add({ extension = { slint = "slint" } })

-- Make cursor blink nicely
vim.o.guicursor = table.concat({
    "n-v-c:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100",
    "i-ci:ver25-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100",
    "r:hor50-Cursor/lCursor-blinkwait100-blinkon100-blinkoff100"
}, ",")

-- Folding settings ( I don't use these )
-- vim.opt.foldmethod = "expr"                             -- Use expression for folding
-- vim.wo.vim.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- Use treesitter for folding
-- vim.opt.foldlevel = 99                                  -- Start with all folds open

-- Split behavior
vim.opt.splitbelow = true -- Horizontal splits go below
vim.opt.splitright = true -- Vertical splits go right

-- Key mappings
vim.g.mapleader = " "      -- Set leader key to space
vim.g.maplocalleader = " " -- Set local leader key (NEW)

-- Normal mode mappings
vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Buffer navigation
local function buffer_close()
    vim.cmd(":bp|sp|bn|bd")
end
vim.keymap.set('n', '<S-x>', buffer_close)         -- close a buffer
vim.keymap.set('n', '<S-k>', '<Cmd>bnext<CR>')     -- next buffer
vim.keymap.set('n', '<S-j>', '<Cmd>bprevious<CR>') -- previous buffer

-- Exit terminal mode with escape
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true })

-- Navigate windows with alt + hjkl
local opts = { silent = true }
vim.keymap.set("t", "<A-h>", "<C-\\><C-N><C-w>h", opts)
vim.keymap.set("t", "<A-j>", "<C-\\><C-N><C-w>j", opts)
vim.keymap.set("t", "<A-k>", "<C-\\><C-N><C-w>k", opts)
vim.keymap.set("t", "<A-l>", "<C-\\><C-N><C-w>l", opts)
vim.keymap.set("i", "<A-h>", "<C-\\><C-N><C-w>h", opts)
vim.keymap.set("i", "<A-j>", "<C-\\><C-N><C-w>j", opts)
vim.keymap.set("i", "<A-k>", "<C-\\><C-N><C-w>k", opts)
vim.keymap.set("i", "<A-l>", "<C-\\><C-N><C-w>l", opts)
vim.keymap.set("n", "<A-h>", "<C-w>h", opts)
vim.keymap.set("n", "<A-j>", "<C-w>j", opts)
vim.keymap.set("n", "<A-k>", "<C-w>k", opts)
vim.keymap.set("n", "<A-l>", "<C-w>l", opts)
-- Resize windows with ctrl
vim.keymap.set("n", "<C-h>", "<C-w><", opts)
vim.keymap.set("n", "<C-l>", "<C-w>>", opts)
vim.keymap.set("n", "<C-k>", "<C-w>+", opts)
vim.keymap.set("n", "<C-j>", "<C-w>-", opts)

-- Copy Full File-Path
vim.keymap.set("n", "<leader>pa", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    print("file:", path)
end)

-- Basic autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Return to last edit position when opening files
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

-- Auto-close terminal when process exits
vim.api.nvim_create_autocmd("TermClose", {
    group = augroup,
    callback = function()
        if vim.v.event.status == 0 then
            vim.api.nvim_buf_delete(0, {})
        end
    end,
})

-- Disable line numbers in terminal and start in insert mode
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
        local opts = { buffer = args.buf, silent = true }

        if client and client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_buf_create_user_command(args.buf, "Format", function()
                vim.lsp.buf.format({ async = true })
            end, {})
        end
        if client and client.server_capabilities.codeActionProvider then
            vim.api.nvim_buf_create_user_command(args.buf, "Action", function()
                vim.lsp.buf.code_action()
            end, {})
        end

        -- Everything else uses the nvim 0.11 default LSP/diagnostic keymaps:
        -- grr references, grn rename, gra code action, gri implementation,
        -- grt type definition, gO document symbols, K hover,
        -- <C-s> (insert) signature help, [d/]d diagnostics, <C-w>d diagnostic
        -- float, <C-]> definition via tagfunc. These have no default:
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    end,
})

-- I like the default lsp keymap but it wasn't default in older versions
if vim.fn.has("nvim-0.11") == 0 then
    vim.keymap.set("n", "grn", vim.lsp.buf.rename, { desc = "vim.lsp.buf.rename()" })
    vim.keymap.set({ "n", "x" }, "gra", vim.lsp.buf.code_action, { desc = "vim.lsp.buf.code_action()" })
    vim.keymap.set("n", "grr", vim.lsp.buf.references, { desc = "vim.lsp.buf.references()" })
    vim.keymap.set("n", "gri", vim.lsp.buf.implementation, { desc = "vim.lsp.buf.implementation()" })
    vim.keymap.set("n", "gO", vim.lsp.buf.document_symbol, { desc = "vim.lsp.buf.document_symbol()" })
    vim.keymap.set({ "i", "n" }, "<C-s>", vim.lsp.buf.signature_help, { desc = "vim.lsp.buf.signature_help()" })
end
if vim.fn.has("nvim-0.11.2") == 0 then
    vim.keymap.set("n", "grt", vim.lsp.buf.type_definition, { desc = "vim.lsp.buf.type_definition()" })
end

vim.diagnostic.config({
    virtual_text = false,
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
    -- Open the diagnostic float after jumping. `jump.float` was deprecated in
    -- 0.12 in favour of `jump.on_jump`, which is not understood by older versions.
    jump = vim.fn.has("nvim-0.12") == 1 and {
        on_jump = function(_, bufnr)
            vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
        end,
    } or { float = true },
})

-- Solid borders on LSP hover/signature floats as well
if vim.fn.has("nvim-0.11") == 1 then
    vim.o.winborder = "solid" -- default border for all floating windows
else
    -- vim.lsp.with was deprecated and removed after 0.11, only use it here
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "solid",
    })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "solid",
    })
end

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- Create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    callback = function()
        local dir = vim.fn.expand('<afile>:p:h')
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, 'p')
        end
    end,
})

-- Command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Better diff options
vim.opt.diffopt:append("linematch:60")

-- Performance improvements
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- Create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end

-- Load and configure plugins
require "perpluginconfig"
require "textobjects"
