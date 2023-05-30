{
  stdenv,
  fetchgit,
  openssl,
  python3,
  cmake,
  ninja,
  perl,
  qt6,
  qtbase ? qt6.qtbase,
  qtlanguageserver ? qt6.qtlanguageserver,
  qtshadertools ? qt6.qtshadertools,
  ...
}:
stdenv.mkDerivation rec {
  pname = "qtdeclarative";
  version = "6.5.1";

  src = fetchgit {
    url = "git://code.qt.io/qt/qtdeclarative.git";
    rev = "65651dc1d333e2aded18b0d6f0b71c35e5b40c1c";
    sha256 = "sha256-gOgHMfbAGyW0pHLMp0Y9MKy3ljXu0fpVHxqq6Ww7guo=";
  };

  nativeBuildInputs = [cmake ninja perl];

  moveToDev = false;
  dontWrapQtApps = true;

  outputs = ["out" "dev"];

  propagatedBuildInputs = [
    openssl
    python3
    qtbase
    qtlanguageserver
    qtshadertools
  ];

  buildPhase = ''
    runHook preBuild
    cmake --build . --target qmlls -- -j$NIX_BUILD_CORES
    runHook postBuild
  '';

  # there is a patch on nixpkgs but its in the jsruntime/qvengine.cpp file which
  # I don't think is related to this.
  patches = [];
}
