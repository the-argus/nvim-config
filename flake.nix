{
  description = "flake for packaging portable-nvim-config";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # banner = {
    #   url = "github:the-argus/banner.nix";
    # };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    # banner,
    ...
  }: let
    supportedSystems = let
      inherit (flake-utils.lib) system;
    in [
      system.aarch64-linux
      system.aarch64-darwin
      system.x86_64-linux
    ];
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      devShell =
        pkgs.mkShell
        {
          packages = with pkgs; [
            zig_0_14
            gdb
            (pkgs.writeShellScriptBin "tvim" ''
              export XDG_CONFIG_HOME=$PWD/..
              export NVIM_APPNAME=$(${pkgs.coreutils}/bin/basename $PWD)
              export VIMRUNTIME=$PWD/zig-out/runtime
              export PATH=$PWD/zig-out/bin:$PATH
              nvim -u init.lua $@
            '')
            (pkgs.writeShellScriptBin "debug" ''
              export XDG_CONFIG_HOME=$PWD/..
              export NVIM_APPNAME=$(${pkgs.coreutils}/bin/basename $PWD)
              export VIMRUNTIME=$PWD/zig-out/runtime
              export PATH=$PWD/zig-out/bin:$PATH
              gdb --args nvim -u init.lua $@
            '')
            (pkgs.writeShellScriptBin "build" ''
              zig build -Dtarget=x86_64-linux-musl
            '')
          ];
        };

      packages = let
        mkNeovim = args: pkgs.callPackage ./wrapper.nix args;
      in {
        inherit mkNeovim;

        default = mkNeovim {};

        minimal = mkNeovim {minimal = true;};
      };
    });
}
