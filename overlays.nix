(_: super: {
  vimPlugins = super.vimPlugins.extend (_: superVimPlugins: {
    cmp-nvim-lsp = superVimPlugins.cmp-nvim-lsp.overrideAttrs (_: {
      version = "2022-11-08";
      src = super.fetchgit {
        url = "https://github.com/hrsh7th/cmp-nvim-lsp";
        rev = "78924d1d677b29b3d1fe429864185341724ee5a2";
        sha256 = "1gzn4v70wa61yyw9vfxb8m8kkabz0p35nja1l26cfhl71pnkqrka";
      };
    });
    nvim-tree-lua = superVimPlugins.nvim-tree-lua.overrideAttrs (_: {
      version = "2022-11-08";
      src = super.fetchgit {
        url = "https://github.com/nvim-tree/nvim-tree.lua";
        rev = "7e892767bdd9660b7880cf3627d454cfbc701e9b";
        sha256 = "0jl9vlwa9swlgmlr928d0y9h8vaj3nz3jha9nz94wwavjnb0iwcz";
      };
    });
    base16-nvim = superVimPlugins.nvim-base16.overrideAttrs (_: {
      src = super.fetchgit {
        url = "https://github.com/the-argus/banner.nvim";
        rev = "fd78195b411c103f05eddfc055a743df2de10d63";
        sha256 = "0z62d7dykv9zaz95nrry5j8a2218d7vx3qnpnwfcic9g97kcyip6";
      };
    });
  });
})
