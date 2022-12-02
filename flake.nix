{
  description = "My neovim configuration, packaging managed by nix.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs?rev=e12211201092f08c24d710c1697cca16afae3a4c;
    nixpkgs-old.url = github:NixOS/nixpkgs?ref=nixos-22.11;
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
                nvim-base16 = super.vimPlugins.nvim-base16.overrideAttrs (_: {
                  src = super.fetchgit {
                    url = "https://github.com/the-argus/banner.nvim";
                    rev = "fd78195b411c103f05eddfc055a743df2de10d63";
                    sha256 = "0z62d7dykv9zaz95nrry5j8a2218d7vx3qnpnwfcic9g97kcyip6";
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
              inherit (banner.lib.util) removeMeta;
              inherit (pkgs.${system}.lib) attrsets;
              palette =
                if builtins.typeOf bannerPalette == "set"
                then bannerPalette
                else banner.lib.parsers.basicYamlToBanner bannerPalette;
              lualines =
                attrsets.mapAttrsToList
                (name: value: "${builtins.replaceStrings ["-"] ["_"] name} = \"#${value}\",")
                (removeMeta palette);
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

          # writing plugins
          thesaurus_query-vim
          vim-table-mode

          orgmode
          # neorg # only works with 0.8.0

          # color scheme dev
          lush-nvim
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
        inherit (pkgs.${system}) nodePackages;
        myNodePackages = pkgs.${system}.callPackage ./packages/nodePackages {};

        tsls = nodePackages.typescript-language-server.override {
          nativeBuildInputs = [pkgs.${system}.buildPackages.makeWrapper];
          postInstall = ''
            wrapProgram "$out/bin/typescript-language-server" \
              --prefix NODE_PATH : ${nodePackages.typescript}/lib/node_modules
          '';
        };
      in
        unwrapped-nvim: let
          inherit
            (pkgs.${system})
            bash
            buildPackages
            stdenv
            coreutils-full
            lib
            ;

          binPath = lib.makeBinPath ((with pkgs.${system}; [
              black
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
            ])
            ++ (with nodePackages; [
              vscode-html-languageserver-bin
              vscode-css-languageserver-bin
              bash-language-server
              fixjson
              jsonlint
              markdownlint-cli
              prettier
            ])
            ++ (with myNodePackages; [
              emmet-ls
              ansiblels
              standard
            ])
            ++ [
              tsls
            ]);
        in
          stdenv.mkDerivation {
            name = "configure-nvim";
            src = unwrapped-nvim;
            nativeBuildInputs = [
              buildPackages.makeWrapper
            ];
            installPhase = ''
              runHook preInstall
              cp -r $src $out
              ${coreutils-full}/bin/chmod +w+r $out/bin -R
              runHook postInstall
            '';
            postInstall = ''
              #!${bash}/bin/bash

              for bin in $out/bin/*; do
                wrapProgram "$bin" \
                  --suffix PATH : ${binPath}
              done
            '';
          };
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
          confirm = "31748f";
          warn = "f6c177";
          urgent = "eb6f92";
          link = "9ccfd8";
          highlight = "c4a7e7";
          hialt0 = "f6c177";
          hialt1 = "c4a7e7";
          hialt2 = "f6c177";
          pfg-confirm = "f0f0f3";
          pfg-warn = "191724";
          pfg-urgent = "191724";
          pfg-link = "191724";
          pfg-highlight = "191724";
          pfg-hialt0 = "191724";
          pfg-hialt1 = "191724";
          pfg-hialt2 = "191724";
        };
      });
    });
  };
}
