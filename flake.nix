{
  description = "My neovim configuration, packaging managed by nix.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs?rev=e12211201092f08c24d710c1697cca16afae3a4c;
    nixpkgs-old.url = github:NixOS/nixpkgs?ref=nixos-22.11;
    nixpkgs-unstable.url = github:NixOS/nixpkgs?ref=nixos-unstable;
    neorg-overlay.url = github:nvim-neorg/nixpkgs-neorg-overlay;
    banner = {
      url = "github:the-argus/banner.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-old,
    nixpkgs-unstable,
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
    # pkgs = genSystems (system: mkPkgs system nixpkgs);
    # pkgs-old = genSystems (system: mkPkgs system nixpkgs-old);

    # pkgs = genSystems (system: mkPkgs system nixpkgs-old);
    unstable = genSystems (system: mkPkgs system nixpkgs-unstable);
    pkgs = unstable;
  in {
    packages = genSystems (system: let
      getPlugins = args:
        pkgs.${system}.callPackage ./plugins.nix ({
            unstable = unstable.${system};
            inherit banner;
          }
          // args);

      luaFile = let
        luaBooleans = {
          InNix = true;
          UsingDvorak = false;
        };

        boolToStr = bool:
          if bool
          then "true"
          else "false";

        booleanSedCommands =
          pkgs.${system}.lib.attrsets.mapAttrsToList
          (name: value: ''sed -i "s/\(${name}.*\)\(true\|false\)/\1${boolToStr value}/" init.lua'')
          luaBooleans;

        # lua as a string
        rawLua = builtins.readFile ./init.lua;
        # lua in the nix store
        nixStoreLua = builtins.toFile "init.lua" rawLua;
      in
        pkgs.${system}.stdenv.mkDerivation {
          name = "configure-lua-init-lua";
          src = nixStoreLua;
          dontUnpack = true;
          buildPhase = ''
            cp $src init.lua
            # change booleans to match lua values
            ${builtins.concatStringsSep "\n" booleanSedCommands}
          '';
          installPhase = ''
            mv init.lua $out
          '';
        };

      wrapNeovim = args: pkgs.${system}.callPackage ./wrapper.nix args;
    in rec {
      mkNeovim = args: (
        wrapNeovim ({
            plugins = getPlugins args;
          }
          // (
            if builtins.hasAttr "wrapperArgs" args
            then args.wrapperArgs
            else {}
          ))
      );
      default = mkNeovim {
        bannerPalette = ./default-palette.yaml;
        wrapperArgs = {
          lua = luaFile;
          unwrappedTarget = pkgs.${system}.neovim-unwrapped;
          viAlias = true;
          vimAlias = true;
        };
      };
      rosepine = mkNeovim {
        wrapperArgs = {
          lua = luaFile;
          unwrappedTarget = pkgs.${system}.neovim-unwrapped;
          viAlias = true;
          vimAlias = true;
        };
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
    });
  };
}
