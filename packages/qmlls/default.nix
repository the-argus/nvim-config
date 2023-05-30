# TODO: make this an override of qt6.qtdeclarative. At the moment it does not
# match the qt version on the system.
# or maybe a better solution would be to just provide qmlls per-environment?
{
  stdenv,
  fetchgit,
  openssl,
  python3,
  cmake,
  ninja,
  perl,
  patchelf,
  qt6,
  qtbase ? qt6.qtbase,
  qtlanguageserver ? qt6.qtlanguageserver,
  qtshadertools ? qt6.qtshadertools,
  ...
}:
stdenv.mkDerivation rec {
  pname = "qmlls";
  version = "6.5.1";

  src = fetchgit {
    url = "git://code.qt.io/qt/qtdeclarative.git";
    rev = "65651dc1d333e2aded18b0d6f0b71c35e5b40c1c";
    sha256 = "sha256-gOgHMfbAGyW0pHLMp0Y9MKy3ljXu0fpVHxqq6Ww7guo=";
  };

  nativeBuildInputs = [cmake ninja perl patchelf];

  dontWrapQtApps = true;

  propagatedBuildInputs = [
    openssl
    python3
    qtbase
    qtlanguageserver
    qtshadertools
  ];

  configurePhase = ''
    runHook preConfigure

    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$out

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    local flagsArray=(SHELL=$SHELL)

    cmake --build build/ --target qmlls -- "${"$\{flagsArray[@]}"}" -j$NIX_BUILD_CORES
    unset flagsArray

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    # manually install because cmake --install doesnt work when building only
    # one target
    # TODO: use out/dev outputs
    cd build
    mv lib/ $out/lib
    mv bin/ $out/bin
    mv libexec/ $out/libexec
    mv include/ $out/include
    cd ..

    runHook postInstall
  '';

  # there is a patch on nixpkgs but its in the jsruntime/qvengine.cpp file which
  # I don't think is related to this.
  patches = [];
}
