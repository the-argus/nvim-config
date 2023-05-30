{
  stdenv,
  fetchgit,
  openssl,
  python3,
  qtbase,
  qtlanguageserver,
  qtshadertools,
  ...
}:
stdenv.mkDerivation rec {
  pname = "qtdeclarative";
  version = "6.5.1";

  src = fetchgit {
    url = "git://code.qt.io/qt/qtdeclarative.git";
    rev = "65651dc1d333e2aded18b0d6f0b71c35e5b40c1c";
    sha256 = "";
  };

  nativeBuildInputs =
    [cmake ninja perl]
    ++ lib.optionals stdenv.isDarwin [moveBuildTree];

  moveToDev = false;

  outputs = args.outputs or ["out" "dev"];

  propagatedBuildInputs = [
    openssl
    python3
    qtbase
    qtlanguageserver
    qtshadertools
  ];

  cmakeFlags = ["-DQT_BUILD_SINGLE_TARGET_SET=Qt::LanguageServerPrivate"];

  # there is a patch on nixpkgs but its in the jsruntime/qvengine.cpp file which
  # I don't think is related to this.
  patches = [];
}
