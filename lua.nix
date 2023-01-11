{
  stdenv,
  lib,
  UsingDvorak ? false,
  ...
}: let
  luaBooleans = {
    InNix = true;
    inherit UsingDvorak;
  };

  boolToStr = bool:
    if bool
    then "true"
    else "false";

  booleanSedCommands =
    lib.attrsets.mapAttrsToList
    (name: value: ''sed -i "s/\(${name}.*\)\(true\|false\)/\1${boolToStr value}/" init.lua'')
    luaBooleans;

  # lua as a string
  rawLua = builtins.readFile ./init.lua;
  # lua in the nix store
  nixStoreLua = builtins.toFile "init.lua" rawLua;
in
  stdenv.mkDerivation {
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
  }
