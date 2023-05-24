{qt6, ...}: let
  cmakeBegin = builtins.toFile "cmakeMiddle" ''
    cmake_minimum_required(VERSION 3.16)
    project(QtDeclarative # special case
        VERSION "${"$\{QT_REPO_MODULE_VERSION}"}"
        DESCRIPTION "Qt Declarative Libraries" # special case
        HOMEPAGE_URL "https://qt.io/"
        LANGUAGES CXX C
    )
    # list all the deps for qmlls here
    find_package(Qt6 ${"$\{PROJECT_VERSION}"} CONFIG REQUIRED COMPONENTS BuildInternals Core)
    find_package(Qt6 ${"$\{PROJECT_VERSION}"} QUIET CONFIG OPTIONAL_COMPONENTS Gui Network Widgets OpenGL OpenGLWidgets Sql Concurrent Test LanguageServerPrivate LinguistTools)
  '';
in
  qt6.qtdeclarative.overrideAttrs (_: {
    postPatch = ''
      QMLCMAKEFILE=tools/qmlls/CMakeLists.txt
      TEMP=temp.cmake
      cp $QMLCMAKEFILE $TEMP
      cat .cmake.conf > $QMLCMAKEFILE # wipe the original file
      cat ${cmakeBegin} >> $QMLCMAKEFILE
      cat $TEMP >> $QMLCMAKEFILE # bring back the contents of the original file

      cd tools/qmlls
    '';
  })
