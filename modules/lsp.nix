{
  pkgs,
  dsl,
  ...
}:
with dsl; {
  plugins = with pkgs.vimPlugins; [
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

  use.lspconfig = let
    # this doesn't actually do anything at the moment...
    servers = [
      "clangd"
      "rnix"
      "pyright"
      "html"
      "sumneko_lua"
      "bashls"
      "cssls"

      "quick_lint_js"
      "lemminx"
      "rust_analyzer"
      "ansiblels"
      "emmet_ls"
    ];
  in {
    pyright.setup =
      callWith {cmd = ["${pkgs.pyright}/bin/pyright-langserver" "--stdio"];};

    rnix.setup = callWith {
      autostart = true;
      cmd = ["${pkgs.rnix-lsp}/bin/rnix-lsp"];
      capabilities =
        rawLua
        "require('cmp_nvim_lsp').default_capabilities()";
    };

    quick_lint_js.setup = callWith {
      cmd = [
        "${pkgs.quick-lint-js}/bin/quick-lint-js"
      ];
    };

    clangd.setup =
      callWith {cmd = ["${pkgs.clang-tools}/bin/clangd"];};

    sumneko_lua.setup =
      callWith {cmd = ["${pkgs.sumneko-lua-language-server}/bin/lua-language-server"];};

    bashls.setup = callWith {
      cmd = ["${pkgs.nodePackages.bash-language-server}/bin/bash-language-server"];
    };

    cssls.setup = callWith {
      cmd = [
        "${pkgs.nodePackages.vscode-css-languageserver-bin}/bin/css-languageserver"
        "--stdio"
      ];
    };

    html.setup = callWith {
      cmd = [
        "${pkgs.nodePackages.vscode-html-languageserver-bin}/bin/html-languageserver"
        "--stdio"
      ];
      init_options = {
        configurationSection = ["html" "css" "javascript"];
        embeddedLanguages = {
          css = true;
          javascript = true;
        };
        provideFormatter = true;
      };
    };
  };
}
