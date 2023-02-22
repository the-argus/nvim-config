{
  nodePackages,
  callPackage,
  buildPackages,
  wrapNeovimUnstable,
  neovimUtils,
  lib,
  # sorry about using this but I want to only specify LSPs once
  pkgs,
  writeText,
  plugins ? [],
  lua ? (writeText "init.lua" ""),
  neovim-unwrapped,
  unwrappedTarget ? neovim-unwrapped,
  extraLuaPackages ? (_: []),
  extraPython3Packages ? (_: []),
  withPython3 ? true,
  withRuby ? false,
  viAlias ? false,
  vimAlias ? false,
  minimal,
  ...
}: let
  myNodePackages = callPackage ./packages/nodePackages {};
  ical2org = callPackage ./packages/ical2org {
    author = "Ian McFarlane";
    email = "i.mcfarlane2002@gmail.com";
  };

  tsls = nodePackages.typescript-language-server.override {
    nativeBuildInputs = [buildPackages.makeWrapper];
    postInstall = ''
      mkdir -p $out/node_modules/
      ln -sf ${nodePackages.typescript}/lib/node_modules/typescript $out/node_modules/typescript
    '';
  };

  luaFile =
    if builtins.typeOf lua == "path" || builtins.typeOf lua == "set"
    then lua
    else abort "Invalid type for \"lua\" argument: ${builtins.typeOf lua}. Expected \"set\" or \"path\". Ensure lua is a derivation or a path to one.";

  vimConfig = ''luafile ${luaFile}'';

  minimalBinPath = lib.makeBinPath (with pkgs; [
    clang-tools
    rnix-lsp
    alejandra
    nodePackages.bash-language-server
    nodePackages.jsonlint
    nodePackages.markdownlint-cli
    nodePackages.prettier
    yamllint
  ]);

  maximalBinPath = lib.makeBinPath ((with pkgs; [
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
      nimlsp
      # nim
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
      ical2org
    ]);

  binPath =
    if minimal
    then minimalBinPath
    else maximalBinPath;

  neovimConfig = neovimUtils.makeNeovimConfig {
    inherit plugins extraPython3Packages withPython3 withRuby viAlias vimAlias;
    customRC = vimConfig;
  };

  # this bit is stolen from https://github.com/nix-community/home-manager/blob/master/modules/programs/neovim.nix
  luaPackages = unwrappedTarget.lua.pkgs;
  resolvedExtraLuaPackages = extraLuaPackages luaPackages;

  makeWrapperArgsFromPackages = op:
    lib.lists.foldr
    (next: prev: prev ++ [";" (op next)]) []
    resolvedExtraLuaPackages;

  extraMakeWrapperLuaCArgs =
    lib.optionals (resolvedExtraLuaPackages != [])
    (["--suffix" "LUA_CPATH" ";"]
      ++ (makeWrapperArgsFromPackages luaPackages.getLuaCPath));
  extraMakeWrapperLuaArgs =
    lib.optionals (resolvedExtraLuaPackages != [])
    (["--suffix" "LUA_PATH" ";"]
      ++ (makeWrapperArgsFromPackages luaPackages.getLuaPath));

  wrapperArgs =
    neovimConfig.wrapperArgs
    ++ extraMakeWrapperLuaArgs
    ++ extraMakeWrapperLuaCArgs
    ++ ["--suffix" "PATH" ":" "${binPath}"];
in
  wrapNeovimUnstable unwrappedTarget (neovimConfig
    // {inherit wrapperArgs;})
