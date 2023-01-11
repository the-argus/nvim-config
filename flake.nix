{
  description = "My neovim configuration, packaging managed by nix.";

  inputs = {
    # nixpkgs.url = github:NixOS/nixpkgs?rev=e12211201092f08c24d710c1697cca16afae3a4c;
    nixpkgs.url = github:NixOS/nixpkgs?ref=nixos-unstable;
    neorg-overlay.url = github:nvim-neorg/nixpkgs-neorg-overlay;
    banner = {
      url = "github:the-argus/banner.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    neorg-overlay,
    banner,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    mkPkgs = system: nixpkgSet:
      import nixpkgSet {
        overlays = [
          neorg-overlay.overlays.default
          (import ./overlays.nix)
        ];
        inherit system;
      };
    # unstable and pkgs are the same thing as of now.
    unstable = genSystems (system: mkPkgs system nixpkgs);
    pkgs = unstable;
  in {
    packages = genSystems (system: let
      # function to get plugins based on inputs
      getPlugins = args:
        pkgs.${system}.callPackage ./plugins.nix ({
            unstable = unstable.${system};
            inherit banner;
          }
          // args);
      
      # turns init.lua into a /nix/store file, plus some settings
      luaFile = pkgs.${system}.callPackage ./lua.nix {UsingDvorak = false;};

      wrapNeovim = args: pkgs.${system}.callPackage ./wrapper.nix args;
    
      # function that combines luaFile, getPlugins, and the wrappers
      defaultWrapperArgs = {lua = luaFile;};
      defaultPluginsArgs = {bannerPalette = ./default-palette.yaml;};
      mkNeovim = {
        pluginsArgs ? defaultPluginsArgs,
        wrapperArgs ? defaultWrapperArgs,
        ...
      }: (
        wrapNeovim ({
            plugins = getPlugins pluginsArgs;
          }
          // wrapperArgs)
      );
    in {
      inherit mkNeovim;

      default = mkNeovim {};

      rosepine = mkNeovim {
        wrapperArgs = {
          viAlias = true;
          vimAlias = true;
        };
        pluginsArgs = {
          bannerPalette = {
            base00 = "191724";
            base01 = "1f1d2e";
            base02 = "26233a";
            base03 = "555169";
            base04 = "6e6a86";
            base05 = "e0def4";
            base06 = "f0f0f3";
            base07 = "c5c3ce";
            base08 = "e2e1e7";
            base09 = "eb6f92";
            base0A = "f6c177";
            base0B = "ebbcba";
            base0C = "31748f";
            base0D = "9ccfd8";
            base0E = "c4a7e7";
            base0F = "e5e5e5";
            confirm = "31748f";
            warn = "f6c177";
            urgent = "eb6f92";
            link = "9ccfd8";
            highlight = "c4a7e7";
            hialt0 = "f6c177";
            hialt1 = "c4a7e7";
            hialt2 = "f6c177";
            pfg-confirm = "f0f0f3";
            pfg-warn = "191724";
            pfg-urgent = "191724";
            pfg-link = "191724";
            pfg-highlight = "191724";
            pfg-hialt0 = "191724";
            pfg-hialt1 = "191724";
            pfg-hialt2 = "191724";
          };
        };
      };
    });
  };
}
