{
  callPackage,
  stdenv,
  coreutils-full,
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
        mkdir -p $out
        for file in lib/node_modules/${pkgName}/*; do
          ln -sf $file $out/$(${coreutils-full}/bin/basename $file)
        done
      '';
    };

  overrides = rec {
    emmet-ls = mkNodeWrapper rec {
      pkgName = "emmet-ls";
      extraInstall = ''
        mkdir -p lib/node_modules/${pkgName}/bin
        mv lib/node_modules/${pkgName}/out/server.js lib/node_modules/${pkgName}/bin/emmet-ls
        ${coreutils-full}/bin/chmod +x lib/node_modules/${pkgName}/bin/emmet-ls
      '';
    };

    ansiblels = mkNodeWrapper {pkgName = "@ansible/ansible-language-server";};

    typescript-language-server = mkNodeWrapper {pkgName = "typescript-language-server";};

    standard = mkNodeWrapper {
      pkgName = "standard";
      extraInstall = ''
        mv lib/node_modules/standard/bin/cmd.js lib/node_modules/standard/bin/standard.js
      '';
    };
  };
in
  nodePackages // overrides
