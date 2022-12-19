{
  gawk,
  runtimeShell,
  writeScriptBin,
  coreutils-full,
  author ? "unknown author",
  email ? "unknown@unknown.domain",
  ...
}: let
  awkScript = builtins.toFile "ical2org.awk" (builtins.readFile ./ical2org.awk);
in
  writeScriptBin "ical2org" ''
    #!${runtimeShell}
    if [ "$1" = "--help" ]; then
        echo "ical2org usage: ical2org [input .ics file] [output .org file]"
    fi
    if [ -z $1 ] || [-z $2 ]; then
        echo "please provide arguments [input .ics file] and [output .org file]"
        exit 1
    fi

    if [ -z $AUTHOR ]; then
        export AUTHOR="${author}"
    fi
    if [ -z $EMAIL ]; then
        export EMAIL="${email}"
    fi
    if [ -z $TITLE ]; then
        export TITLE="new-calendar-item-$(${coreutils-full}/bin/date +%m_%d_%y-%M_%S)"
    fi

    ${gawk}/bin/awk -f ${awkScript} < $1 > $2
  ''
