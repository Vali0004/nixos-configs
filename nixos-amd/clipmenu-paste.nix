{ writeScriptBin
, lib
, coreutils-full
, clipmenu
, dmenu
, gawk
, xdotool
, xsel
}:

writeScriptBin "clipmenu-paste" ''
  PATH=${lib.makeBinPath [ clipmenu coreutils-full dmenu gawk xdotool xsel ]}

  selection="$(CM_OUTPUT_CLIP=1 clipmenu)"
  if [ -n "$selection" ]; then
    printf "%s" "$selection" | xsel --clipboard
    sleep 0.1
    xdotool key --clearmodifiers ctrl+v
  fi
''
