{
  stdenv,
  banner,
  lib,
  vimPlugins,
  writeText,
  unstable,
  bannerPalette ? "./default-palette.yaml",
  ...
}:
with vimPlugins; [
  # the lua in this directory is a plugin in itself
  (stdenv.mkDerivation {
    name = "nvim-config";
    src = ./lua;
    installPhase = let
      inherit (banner.lib.util) removeMeta;
      inherit (lib) attrsets;
      palette =
        if builtins.typeOf bannerPalette == "set"
        then bannerPalette
        else banner.lib.parsers.basicYamlToBanner bannerPalette;
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

        tree-sitter-norg
        # tree-sitter-org-nvim
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

  # nice way of displaying multiple diagnostics on a single line
  lsp_lines-nvim

  friendly-snippets
  popup-nvim
  plenary-nvim

  # writing plugins
  thesaurus_query-vim
  vim-table-mode

  # orgmode
  neorg
  neorg-telescope

  # color scheme dev
  lush-nvim

  # nim
  nim-vim

  # helps nesting to look better
  indent-blankline-nvim

  unstable.vimPlugins.yuck-vim
]
