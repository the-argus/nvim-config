{
  pkgs,
  minimal ? false,
  callPackage,
  zls,
  latestZls ? zls,
  wrapNeovimUnstable,
  lib,
  plugins ? [],
  # a directory containing the init.lua and other lua config files, and optionally pack/plugins/start
  configDirectory ? (lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./init.lua
      ./lua
      ./pack
    ];
  }),
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
  clangdWrapper = {
    stdenv,
    clang-tools,
    makeWrapper,
    emptyDirectory,
  }:
    stdenv.mkDerivation {
      pname = "clangd-wrapped";
      version = clang-tools.version;

      src = emptyDirectory;

      dontUnpack = true;
      dontBuild = true;

      buildInputs = [makeWrapper clang-tools];

      postInstall = ''
        mkdir $out/bin -p
        cp ${clang-tools}/bin/clangd $out/bin/clangd

        # make changes to what is about to become .clangd-wrapped, it's a
        # wrapper of a wrapper so it's just a script
        substituteInPlace $out/bin/clangd \
          --replace "\$(basename \$0)" "clangd"

        wrapProgram $out/bin/clangd \
          --add-flags "--experimental-modules-support"
      '';
    };

  # set up lua dir as the config dir of neovim
  vimConfig = ''
    local cfg = '${configDirectory}'
    if vim.fn.isdirectory(cfg) == 1 then
      vim.opt.runtimepath:prepend(cfg)
      vim.opt.packpath:prepend(cfg)
      dofile(cfg .. '/init.lua')
    else
      dofile(cfg)
    end
  '';

  minimalBinPath = with pkgs; [
    (pkgs.callPackage clangdWrapper {clang-tools = pkgs.llvmPackages_21.clang-tools;})
    nil
    alejandra
    yamllint
    bash-language-server
    # jsonlint
    markdownlint-cli
    prettier
  ];

  maximalBinPath =
    (with pkgs; [
      black
      deadnix
      jdt-language-server
      lua-language-server
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
      typescript-language-server
      # emmet-ls
      # ansiblels
      # standard
    ])
    ++ minimalBinPath;

  binPath =
    lib.makeBinPath
    (
      if minimal
      then minimalBinPath
      else maximalBinPath
    );

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
    extraMakeWrapperLuaArgs
    ++ extraMakeWrapperLuaCArgs
    ++ ["--suffix" "PATH" ":" "${binPath}"]
    ++ (lib.optionals (!minimal) ["--set" "JDTLS_INSTALL_PATH" "${pkgs.jdt-language-server}"]);
in
  wrapNeovimUnstable unwrappedTarget ({
      inherit plugins extraPython3Packages withPython3 withRuby viAlias vimAlias;
      # NOTE: wrapNeovimUnstable takes luaRcContent/neovimRcContent, not
      # customRC (that was a makeNeovimConfig argument; passing it here is
      # silently ignored)
      luaRcContent = vimConfig;
    }
    // {inherit wrapperArgs;})
