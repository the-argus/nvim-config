{
  nodePackages,
  callPackage,
  latestZls,
  wrapNeovimUnstable,
  neovimUtils,
  lib,
  # sorry about using this but I want to only specify LSPs once
  pkgs,
  useQmlls,
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

  tsls = nodePackages.typescript-language-server;

  luaFile =
    if builtins.typeOf lua == "path" || builtins.typeOf lua == "set"
    then lua
    else abort "Invalid type for \"lua\" argument: ${builtins.typeOf lua}. Expected \"set\" or \"path\". Ensure lua is a derivation or a path to one.";

  vimConfig = ''luafile ${luaFile}'';

  minimalBinPath =
    (with pkgs; [
      clang-tools
      nil
      alejandra
      yamllint
    ])
    ++ (with nodePackages; [
      bash-language-server
      # jsonlint
      markdownlint-cli
      prettier
    ]);

  maximalBinPath =
    ((with pkgs; [
        black
        deadnix
        jdt-language-server
        sumneko-lua-language-server
        # rustfmt
        pyright
        # proselint # i dont have this set up properly
        statix
        rust-analyzer
        nimlsp
        nim
        latestZls
        slint-lsp
        omnisharp-roslyn
        cmake-language-server
        vscode-langservers-extracted
      ])
      ++ (with myNodePackages; [
        emmet-ls
        # ansiblels
        # standard
      ])
      ++ [
        tsls
        ical2org
      ])
    ++ (lib.lists.optionals useQmlls [
      pkgs.qmlls
    ])
    ++ minimalBinPath;

  binPath =
    lib.makeBinPath
    (
      if minimal
      then minimalBinPath
      else maximalBinPath
    );

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
    ++ ["--suffix" "PATH" ":" "${binPath}"]
    ++ (lib.optionals (!minimal) ["--set" "JDTLS_INSTALL_PATH" "${pkgs.jdt-language-server}"]);
in
  wrapNeovimUnstable unwrappedTarget (neovimConfig
    // {inherit wrapperArgs;})
