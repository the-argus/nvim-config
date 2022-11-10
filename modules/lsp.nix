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

  # setup.null-ls = {
  #   debug = false;
  #   sources = let
  #     formatting = parser: rawLua "require(\"null-ls\").builtins.formatting.${parser}";
  #     diagnostics = parser: rawLua "require(\"null-ls\").builtins.diagnostics.${parser}";
  #   in [
  #     (formatting "alejandra")
  #     (diagnostics "deadnix")
  #   ];
  # };

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
      callWith {cmd = ["pyright-langserver" "--stdio"];};

    rnix.setup = callWith {
      autostart = true;
      cmd = ["${pkgs.rnix-lsp}/bin/rnix-lsp"];
      capabilities =
        rawLua
        "require('cmp_nvim_lsp').default_capabilities()";
    };

    # quick_lint_js.setup = callWith {
    #   cmd = [
    #     "quick-lint-js"
    #   ];
    # };

    clangd.setup =
      callWith {cmd = ["clangd"];};

    sumneko_lua.setup =
      callWith {cmd = ["lua-language-server"];};

    bashls.setup = callWith {
      cmd = ["bash-language-server"];
    };

    cssls.setup = callWith {
      cmd = [
        "css-languageserver"
        "--stdio"
      ];
    };

    html.setup = callWith {
      cmd = [
        "html-languageserver"
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
