local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    }
    print "Installing packer close and reopen Neovim..."
    vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
--[[
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]
--]]
-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float { border = "rounded" }
        end,
    },
}

-- Install your plugins here
return packer.startup(function(use)
    -- My plugins here
    use "wbthomason/packer.nvim" -- Have packer manage itself
    use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
    use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins

    -- helpful for commenting out selection
    use "numToStr/Comment.nvim"
    use "folke/todo-comments.nvim"
    -- use {
    --     "numToStr/Comment.nvim",
    --     config = function()
    --         require "plugin-config/comment-nvim"
    --     end,
    --     event = { "InsertEnter" },
    -- }
    -- cmp plugins
    use "hrsh7th/nvim-cmp"
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-nvim-lua"

    use "hrsh7th/cmp-path"
    use "hrsh7th/cmp-buffer"
    use "hrsh7th/cmp-cmdline"
    use "saadparwaiz1/cmp_luasnip"

    -- snippets
    use "L3MON4D3/LuaSnip" --snippet engine
    use "rafamadriz/friendly-snippets" -- a bunch of snippets to use
    -- LSP
    use "neovim/nvim-lspconfig" -- enable LSP
    use "williamboman/nvim-lsp-installer" -- simple to use language server installer

    -- syntax highlighting
    use "nvim-treesitter/nvim-treesitter"
    -- r'ainbow brackets
    use "p00f/nvim-ts-rainbow"

    -- banner  colorscheme
    use "the-argus/banner.nvim"

    -- file tree
    use {
        'kyazdani42/nvim-tree.lua',
        requires = {
            'kyazdani42/nvim-web-devicons', -- optional, for file icon
        }
    }

    -- focus mode
    use "folke/zen-mode.nvim"
    use "folke/twilight.nvim"

    use 'lewis6991/gitsigns.nvim'

    use {
        'akinsho/bufferline.nvim',
        tag = "*",
        requires = 'kyazdani42/nvim-web-devicons'
    }

    use "jose-elias-alvarez/null-ls.nvim" -- for formatters and linters
    use "sakhnik/nvim-gdb"
    use "gpanders/editorconfig.nvim"

    -- cringe vimscript, really good plugins though
    use "tpope/vim-surround" -- act on surrounding characters
    -- lua rewrite of tpope/vim-surround
    -- use {
    --     "ur4ltz/surround.nvim",
    --     config = function()
    --         require "surround".setup { mappings_style = "surround" }
    --     end
    -- }
    use "tpope/vim-repeat" -- repeat plugin motions
    use "gbprod/substitute.nvim" -- motion to substitute with current register
    -- use "inkarkat/vim-ReplaceWithRegister"
    use "michaeljsmith/vim-indent-object" -- treat indentations as text objects
    -- treat lines as text objects (starting from after whitespace)
    use "kana/vim-textobj-user"
    use "kana/vim-textobj-line"

    use "norcalli/nvim-colorizer.lua"
    use "tikhomirov/vim-glsl"

    -- use { 'nvim-telescope/telescope-fzf-native.nvim',
    --     run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
    use {
        'nvim-telescope/telescope.nvim', branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' }, { 'kyazdani42/nvim-web-devicons' } }
    }

    -- generate dummy text
    use "derektata/lorem.nvim"

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
