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
  configDirectory ? (
    lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./init.lua
        ./lua
        ./pack
      ];
    }
  ),
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

      buildInputs = [
        makeWrapper
        clang-tools
      ];

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

  minimalTreesitterLanguages = [
    "bash"
    "c"
    "cmake"
    "comment"
    "cpp"
    "css"
    "diff"
    "dockerfile"
    "editorconfig"
    "gitattributes"
    "gitcommit"
    "gitignore"
    "git_rebase"
    "html"
    "ini"
    "javascript"
    "json"
    "lua"
    "luadoc"
    "make"
    "markdown"
    "markdown_inline"
    "nix"
    "python"
    "query"
    "regex"
    "toml"
    "tsx"
    "typescript"
    "vim"
    "vimdoc"
    "xml"
    "yaml"
  ];

  maximalTreesitterLanguages =
    [
      "asm"
      "c_sharp"
      "doxygen"
      "gdscript"
      "gdshader"
      "glsl"
      "go"
      "godot_resource"
      "hlsl"
      "java"
      "just"
      "kotlin"
      "meson"
      "nim"
      "objc"
      "odin"
      "printf"
      "rust"
      "scss"
      "slint"
      "strace"
      "swift"
      "wgsl"
      "zig"
      "zsh"
    ]
    ++ minimalTreesitterLanguages;

  treesitterGrammars = let
    inherit (pkgs.vimPlugins) nvim-treesitter;

    wanted =
      if minimal
      then minimalTreesitterLanguages
      else maximalTreesitterLanguages;

    # some lanaguages depend on other grammars, such as C -> C++.
    requiresOf = lang:
      (nvim-treesitter.parsers.${lang}.requires or [])
      ++ (nvim-treesitter.queries.${lang}.requires or []);

    languages = map (entry: entry.key) (
      lib.genericClosure {
        startSet = map (lang: {key = lang;}) wanted;
        operator = entry: map (lang: {key = lang;}) (requiresOf entry.key);
      }
    );
  in
    pkgs.symlinkJoin {
      name = "nvim-treesitter-grammars";
      paths =
        lib.concatMap (
          lang:
            lib.optional (nvim-treesitter.parsers ? ${lang}) nvim-treesitter.parsers.${lang}
            ++ lib.optional (nvim-treesitter.queries ? ${lang}) nvim-treesitter.queries.${lang}
        )
        languages;
    };

  binPath = lib.makeBinPath (
    if minimal
    then minimalBinPath
    else maximalBinPath
  );

  # this bit is stolen from https://github.com/nix-community/home-manager/blob/master/modules/programs/neovim.nix
  luaPackages = unwrappedTarget.lua.pkgs;
  resolvedExtraLuaPackages = extraLuaPackages luaPackages;

  makeWrapperArgsFromPackages = op:
    lib.lists.foldr (
      next: prev:
        prev
        ++ [
          ";"
          (op next)
        ]
    ) []
    resolvedExtraLuaPackages;

  extraMakeWrapperLuaCArgs = lib.optionals (resolvedExtraLuaPackages != []) (
    [
      "--suffix"
      "LUA_CPATH"
      ";"
    ]
    ++ (makeWrapperArgsFromPackages luaPackages.getLuaCPath)
  );
  extraMakeWrapperLuaArgs = lib.optionals (resolvedExtraLuaPackages != []) (
    [
      "--suffix"
      "LUA_PATH"
      ";"
    ]
    ++ (makeWrapperArgsFromPackages luaPackages.getLuaPath)
  );

  wrapperArgs =
    extraMakeWrapperLuaArgs
    ++ extraMakeWrapperLuaCArgs
    ++ [
      "--suffix"
      "PATH"
      ":"
      "${binPath}"
    ]
    ++ (lib.optionals (!minimal) [
      "--set"
      "JDTLS_INSTALL_PATH"
      "${pkgs.jdt-language-server}"
    ]);
in
  wrapNeovimUnstable unwrappedTarget (
    {
      inherit
        extraPython3Packages
        withPython3
        withRuby
        viAlias
        vimAlias
        ;
      plugins = plugins ++ [treesitterGrammars];
      luaRcContent = vimConfig;
    }
    // {
      inherit wrapperArgs;
    }
  )
