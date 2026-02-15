{
  stdenv,
  banner,
  lib,
  vimPlugins,
  writeText,
  unstable,
  bannerPalette ? "",
  minimal,
  ...
}: (with vimPlugins;
  [
    # the lua in this directory is a plugin in itself
    (stdenv.mkDerivation {
      name = "nvim-config";
      src = ./lua;
      installPhase = let
        inherit (banner.lib.util) removeMeta;
        inherit (lib) attrsets;
        paletteRaw =
          if builtins.typeOf bannerPalette == "set"
          then bannerPalette
          else banner.lib.parsers.basicYamlToBanner ./default-palette.yaml;
        # replace comment color with a highlight color
        palette = paletteRaw // { base03 = paletteRaw.base0C; };
        lualines =
          attrsets.mapAttrsToList
          (name: value: "${builtins.replaceStrings ["-"] ["_"] name} = \"#${value}\",")
          (removeMeta palette);
        color-lua = writeText "color.lua" ''
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

    base16-nvim

    comment-nvim

    todo-comments-nvim

    # (pkgs.${system}.vimPlugins.nvim-treesitter.withPlugins
    #  (_: pkgs.${system}.tree-sitter.allGrammars))

    (nvim-treesitter.withPlugins (plugins:
      # with pkgs-old.${system}.tree-sitter-grammars; [
      (with plugins;
        [
          tree-sitter-yaml
          tree-sitter-toml
          tree-sitter-regex
          tree-sitter-python
          tree-sitter-nix
          tree-sitter-markdown
          tree-sitter-make
          tree-sitter-json
          tree-sitter-dockerfile
          tree-sitter-comment
          tree-sitter-cmake
          tree-sitter-c
          tree-sitter-cpp
          tree-sitter-bash
        ]
        ++ (lib.lists.optionals (!minimal) (with plugins; [
          tree-sitter-godot-resource
          tree-sitter-rust
          tree-sitter-scss
          tree-sitter-lua
          tree-sitter-css
          tree-sitter-javascript
          tree-sitter-java
          tree-sitter-glsl
          tree-sitter-gdscript
          tree-sitter-c-sharp
          tree-sitter-norg
          # tree-sitter-org-nvim
          tree-sitter-zig
          tree-sitter-gdshader
          tree-sitter-tsx
          tree-sitter-zsh
          tree-sitter-wgsl
          tree-sitter-vim
          tree-sitter-typescript
          tree-sitter-strace
          tree-sitter-slint
          tree-sitter-qmljs
          tree-sitter-qmldir
          tree-sitter-printf
          tree-sitter-odin
          tree-sitter-meson
          tree-sitter-go
          tree-sitter-gitignore
          tree-sitter-gitcommit
          tree-sitter-git_rebase
          tree-sitter-bitbake
        ])))))
    rainbow-delimiters-nvim

    vim-glsl

    nvim-tree-lua
    telescope-file-browser-nvim
    nvim-web-devicons

    gitsigns-nvim

    bufferline-nvim

    vim-qml

    editorconfig-nvim

    vim-surround # surround-nvim is rewrite, figure that out
    vim-indent-object
    vim-repeat
    substitute-nvim
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
    cmp-path # cmp-fuzzy-path
    cmp-buffer # cmp-fuzzy-buffer
    cmp-cmdline # cmp-cmdline-history

    nvim-lspconfig
    none-ls-nvim

    friendly-snippets
    popup-nvim
    plenary-nvim

    # helps nesting to look better
    indent-blankline-nvim
  ]
  ++ (lib.lists.optionals (!minimal) (with vimPlugins; [
    cmp_luasnip
    luasnip
    cmp-nvim-lua

    # nice way of displaying multiple diagnostics on a single line
    lsp_lines-nvim
    zen-mode-nvim
    twilight-nvim
    unstable.vimPlugins.yuck-vim

    # writing plugins
    thesaurus_query-vim
    vim-table-mode

    # orgmode
    # neorg
    # neorg-telescope

    # color scheme dev
    lush-nvim

    # nim
    nim-vim

    nvim-dap

    # better csharp support
    omnisharp-extended-lsp-nvim

    # java ls
    nvim-jdtls
  ])))
