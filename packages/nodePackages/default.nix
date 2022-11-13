{
  callPackage,
  stdenv,
  ...
}: let
  nodePackages =
    callPackage ./generated {};
  overrides = rec {
    standard = nodePackages.standard.override {
      dontNpmInstall = true;
    };
    standard-bin = stdenv.mkDerivation {
      name = "standardjs-wrapper";
      src = standard;
      installPhase = ''
        mv lib/node_modules/standard/bin/cmd.js lib/node_modules/standard/bin/standard
        mv lib/node_modules/standard $out
      '';
    };
  };
in
  nodePackages // overrides
