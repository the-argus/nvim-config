{
  description = "My neovim configuration, packaging managed by nix.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    nixpkgs-old.url = github:NixOS/nixpkgs?ref=nixos-22.05;
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
    nixpkgs-old,
    nix2vim,
    banner,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    mkPkgs = system: nixpkgSet:
      import nixpkgSet {
        overlays = [
          nix2vim.overlay
          (_: super: {
            vimPlugins =
              super.lib.trivial.mergeAttrs
              super.vimPlugins
              {
                cmp-nvim-lsp = super.vimPlugins.cmp-nvim-lsp.overrideAttrs (_: {
                  version = "2022-11-08";
                  src = super.fetchgit {
                    url = "https://github.com/hrsh7th/cmp-nvim-lsp";
                    rev = "78924d1d677b29b3d1fe429864185341724ee5a2";
                    sha256 = "1gzn4v70wa61yyw9vfxb8m8kkabz0p35nja1l26cfhl71pnkqrka";
                  };
                });
                nvim-tree-lua = super.vimPlugins.nvim-tree-lua.overrideAttrs (_: {
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
      };
    # pkgs = genSystems (system: mkPkgs system nixpkgs);
    # pkgs-old = genSystems (system: mkPkgs system nixpkgs-old);

    pkgs = genSystems (system: mkPkgs system nixpkgs-old);
  in {
    packages = genSystems (system: let
      mkBuilderInputs = {bannerPalette, ...}: {
        imports = [
          # ./modules/lsp.nix
        ];
        enableViAlias = true;
        enableVimAlias = true;

        plugins = with pkgs.${system}.vimPlugins; [
          # the lua in this directory is a plugin in itself
          (pkgs.${system}.stdenv.mkDerivation {
            name = "nvim-config";
            src = ./lua;
            installPhase = let
              inherit (banner.lib.util) makeBase16 removeMeta;
              palette =
                if builtins.typeOf bannerPalette == "set"
                then bannerPalette
                else banner.lib.parsers.basicYamlToBanner bannerPalette;
              lualines =
                pkgs.${system}.lib.attrsets.mapAttrsToList
                (name: value: "${name} = \"#${value}\",")
                (makeBase16 (removeMeta palette));
              color-lua = pkgs.${system}.writeText "color.lua" ''
                return {
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

          comment-nvim

          # (pkgs.${system}.vimPlugins.nvim-treesitter.withPlugins
          #  (_: pkgs.${system}.tree-sitter.allGrammars))

          (nvim-treesitter.withPlugins (plugins:
            # with pkgs-old.${system}.tree-sitter-grammars; [
              with plugins; [
                tree-sitter-yaml
                tree-sitter-toml
                tree-sitter-rust
                tree-sitter-scss
                tree-sitter-regex
                tree-sitter-python
                tree-sitter-nix
                tree-sitter-markdown
                tree-sitter-make
                tree-sitter-lua
                tree-sitter-json
                tree-sitter-javascript
                tree-sitter-java
                tree-sitter-glsl
                tree-sitter-godot-resource
                tree-sitter-gdscript
                tree-sitter-dockerfile
                tree-sitter-css
                tree-sitter-cpp
                tree-sitter-comment
                tree-sitter-cmake
                tree-sitter-c
                tree-sitter-c-sharp
                tree-sitter-bash
              ]))
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

          friendly-snippets
          popup-nvim
          plenary-nvim
        ];

        lua =
          builtins.replaceStrings
          ["false"]
          ["true"]
          (builtins.readFile ./init.lua);

        withNodeJs = true;
        withPython3 = true;
        extraPython3Packages = packages: with packages; [];
      };

      wrap = let
        inherit
          (pkgs.${system})
          black
          writeShellScriptBin
          bash
          nodePackages
          deadnix
          clang-tools
          rnix-lsp
          sumneko-lua-language-server
          alejandra
          rustfmt
          pyright
          proselint
          statix
          yamllint
          rust-analyzer
          ;
        myNodePackages = pkgs.${system}.callPackage ./packages/nodePackages {};
      in
        unwrapped-nvim:
          writeShellScriptBin "nvim" ''
            #!${bash}/bin/bash

            # LSPs used by lspconfig
            export PATH=$PATH:${clang-tools}/bin
            export PATH=$PATH:${rnix-lsp}/bin
            export PATH=$PATH:${sumneko-lua-language-server}/bin
            export PATH=$PATH:${pyright}/bin
            export PATH=$PATH:${nodePackages.vscode-html-languageserver-bin}/bin
            export PATH=$PATH:${nodePackages.vscode-css-languageserver-bin}/bin
            export PATH=$PATH:${nodePackages.bash-language-server}/bin
            export PATH=$PATH:${myNodePackages.emmet-ls}/bin
            export PATH=$PATH:${myNodePackages.ansiblels}/bin
            export PATH=$PATH:${yamllint}/bin
            export PATH=$PATH:${rust-analyzer}/bin

            # LSPs used by null-ls
            export PATH=$PATH:${black}/bin
            export PATH=$PATH:${nodePackages.markdownlint-cli}/bin
            export PATH=$PATH:${nodePackages.fixjson}/bin
            export PATH=$PATH:${nodePackages.jsonlint}/bin
            export PATH=$PATH:${rustfmt}/bin
            export PATH=$PATH:${alejandra}/bin
            export PATH=$PATH:${statix}/bin
            export PATH=$PATH:${deadnix}/bin
            export PATH=$PATH:${myNodePackages.standard}/bin
            export PATH=$PATH:${nodePackages.prettier}/bin
            export PATH=$PATH:${proselint}/bin
            
            # export PATH=$PATH:$\{nodePackages.cspell}/bin
            # export PATH=$PATH:$\{python310Packages.demjson3}/bin
            # export PATH=$PATH:$\{quick-lint-js}/bin
            # export PATH=$PATH:$\{nodePackages.eslint_d}/bin
            ${unwrapped-nvim}/bin/nvim $@
          '';
    in rec {
      mkNeovim = args: wrap (pkgs.${system}.neovimBuilder (mkBuilderInputs args));
      defaultUnwrapped = pkgs.${system}.neovimBuilder (mkBuilderInputs {
        bannerPalette = ./default-palette.yaml;
      });
      default = wrap defaultUnwrapped;
      rosepine = wrap (mkNeovim {
        bannerPalette = {
          base00 = "191724";
          base01 = "1f1d2e";
          base02 = "26233a";
          base03 = "555169";
          base04 = "6e6a86";
          base05 = "e0def4";
          base06 = "f0f0f3";
          base07 = "c5c3ce";
          base08 = "e2e1e7";
          base09 = "eb6f92";
          base0A = "f6c177";
          base0B = "ebbcba";
          base0C = "31748f";
          base0D = "9ccfd8";
          base0E = "c4a7e7";
          base0F = "e5e5e5";
        };
      });
    });
  };
}
