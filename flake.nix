{
  description = "My neovim configuration, packaging managed by nix.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    nix2vim.url = github:gytis-ivaskevicius/nix2vim;
    nix2vim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nix2vim,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = genSystems (system:
      import nixpkgs {
        overlays = [nix2vim.overlay];
        inherit system;
      });
  in {
    packages = genSystems (system: {
      default = pkgs.${system}.neovimBuilder {
        imports = []; # i do everything in lua
        enableViAlias = true;
        enableVimAlias = true;

        plugins = with pkgs.${system}.vimPlugins; [
          nvim-base16

          friendly-snippets
          popup-nvim
          plenary-nvim
          comment-nvim
          nvim-cmp
          cmp-nvim-lsp
          cmp-nvim-lua
          cmp-path # cmp-fuzzy-path
          cmp-buffer # cmp-fuzzy-buffer
          cmp-cmdline # cmp-cmdline-history
          cmp_luasnip
          luasnip

          nvim-lspconfig
          null-ls-nvim
          
          nvim-treesitter
          nvim-ts-rainbow

          nvim-tree nvim-web-devicons
            
          zen-mode-nvim
          twilight-nvim

          gitsigns-nvim

          bufferline-nvim

          editorconfig-nvim

          vim-surround # surround-nvim is rewrite, figure that out
          vim-indent-object
          vim-repeat
          # look into substitute.nvim
          vim-textobj-comment
          vim-textobj-entire
          vim-textobj-function
          vim-textobj-user
          # look into vim-textobj-line

          nvim-colorizer-lua

          telescope-fzf-native-nvim

          # look into lorem.nvim


        ];

        lua = builtins.readFile ./init.lua;
      };
    });
  };
}
