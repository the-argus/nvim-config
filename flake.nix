{
  description = "My neovim configuration, packaging managed by nix.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    nix2vim.url = github:gytis-ivaskevicius/nix2vim;
    nix2vim.inputs.nixpkgs.follows = "nixpkgs";
    banner = {
      url = "github:the-argus/banner.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix2vim,
    banner,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = genSystems (system:
      import nixpkgs {
        overlays = [
          nix2vim.overlay
          (self: super: {
            vimPlugins =
              super.lib.trivial.mergeAttrs
              super.vimPlugins
              {
                cmp-nvim-lsp = super.vimPlugins.cmp-nvim-lsp.overrideAttrs (oa: {
                  version = "2022-11-08";
                  src = super.fetchgit {
                    url = "https://github.com/hrsh7th/cmp-nvim-lsp";
                    rev = "78924d1d677b29b3d1fe429864185341724ee5a2";
                    sha256 = "1gzn4v70wa61yyw9vfxb8m8kkabz0p35nja1l26cfhl71pnkqrka";
                  };
                });
                nvim-tree-lua = super.vimPlugins.nvim-tree-lua.overrideAttrs (oa: {
                  version = "2022-11-08";
                  src = super.fetchgit {
                    url = "https://github.com/nvim-tree/nvim-tree.lua";
                    rev = "7e892767bdd9660b7880cf3627d454cfbc701e9b";
                    sha256 = "0jl9vlwa9swlgmlr928d0y9h8vaj3nz3jha9nz94wwavjnb0iwcz";
                  };
                });
              };
          })
        ];
        inherit system;
      });
  in {
    packages = genSystems (system: {
      default = pkgs.${system}.neovimBuilder {
        imports = []; # i do everything in lua
        enableViAlias = true;
        enableVimAlias = true;

        plugins = with pkgs.${system}.vimPlugins; [
          # the lua in this directory is a plugin in itself
          (pkgs.${system}.stdenv.mkDerivation {
            name = "nvim-config";
            src = ./lua;
            installPhase = let
              inherit (banner.lib.util) makeBase16 removeMeta;
              palette = banner.lib.parsers.basicYamlToBanner ./default-palette.yaml;
              lualines =
                pkgs.${system}.lib.attrsets.mapAttrsToList
                (name: value: "${name} = \"${value}\",")
                (makeBase16 (removeMeta palette));
              color-lua = pkgs.${system}.writeText "color.lua" ''
                color = {
                	${builtins.concatStringsSep "\n" lualines}
                }
              '';
            in ''
              mkdir -p $out/lua
              mv * $out/lua
              cp ${color-lua} $out/lua/settings/color-palette.lua
            '';
          })

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

          nvim-tree-lua
          nvim-web-devicons

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
