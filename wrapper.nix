{
  stdenv,
  nodePackages,
  callPackage,
  buildPackages,
  coreutils-full,
  wrapNeovimUnstable,
  neovimUtils,
  lib,
  # sorry about using this but I want to only specify LSPs once
  pkgs,
  plugins ? [],
  lua ? "",
  neovim-unwrapped,
  unwrappedTarget ? neovim-unwrapped,
  extraLuaPackages ? (_: []),
  extraPython3Packages ? (_: []),
  withPython3 ? true,
  withRuby ? false,
  viAlias ? false,
  vimAlias ? false,
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
      wrapProgram "$out/bin/typescript-language-server" \
        --prefix NODE_PATH : ${nodePackages.typescript}/lib/node_modules
    '';
  };

  luaFile =
    if builtins.typeOf lua == "path"
    then lua
    else if builtins.typeOf lua == "set"
    then lua
    else abort "Invalid type for \"lua\" argument: ${builtins.typeOf lua}. Expected \"set\" or \"path\". Ensure lua is a derivation or a path to one.";

  vimConfig = ''luafile ${luaFile}'';

  binPath = lib.makeBinPath ((with pkgs; [
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
      ical2org
    ]);

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
