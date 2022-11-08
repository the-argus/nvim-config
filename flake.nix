{
  description = "My neovim configuration, packaging managed by nix.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    nix2vim.url = github:gytis-ivaskevicius/nix2vim;
    nix2vim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nix2vim,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = genSystems (system:
      import nixpkgs {
        overlays = [nix2vim.overlay];
        inherit system;
      });
  in {
    packages = genSystems (system: {
      default = pkgs.${system}.neovimBuilder {
        imports = []; # i do everything in lua
        enableViAlias = true;
        enableVimAlias = true;

        plugins = with pkgs.${system}.vimPlugins; [
          nvim-base16
        ];

        lua = builtins.readFile ./init.lua;
      };
    });
  };
}
