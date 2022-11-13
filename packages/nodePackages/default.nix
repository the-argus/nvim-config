{
  callPackage,
  stdenv,
  ...
}: let
  nodePackages =
    callPackage ./generated {};

  mkNodeWrapper = {
    pkgName,
    extraInstall ? "",
  }:
    stdenv.mkDerivation {
      name = "${pkgName}-wrapper";
      src = nodePackages.${pkgName}.override {
        dontNpmInstall = true;
      };
      installPhase = ''
        ${extraInstall}
        mv lib/node_modules/standard $out
      '';
    };

  overrides = rec {
    emmet-ls = mkNodeWrapper {pkgName = "emmet-ls";};

    ansiblels = mkNodeWrapper {pkgName = "@ansible/ansible-language-server";};

    standard = mkNodeWrapper {
      pkgName = "standard";
      extraInstall = ''
        mv lib/node_modules/standard/bin/cmd.js lib/node_modules/standard/bin/standard.js
      '';
    };
  };
in
  nodePackages // overrides
