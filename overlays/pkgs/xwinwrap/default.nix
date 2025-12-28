{ writeShellScript
, lib
, coreutils
, gnugrep
, mpv
, procps
, xrandr
, xwinwrap
}:

writeScriptBin "xwinwrap-gif" ''
  PATH=${lib.makeBinPath [ coreutils gnugrep mpv procps xrandr xwinwrap ]}
  if [ $# -ne 1 ]; then
    echo 1>&2 Usage: $0 image.gif
    exit 1
  fi

  PIDFILE="/var/run/user/$UID/bg.pid"

  declare -a PIDs

  screen() {
    xwinwrap -ov -ni -g "$1" -- mpv --fullscreen\
        --no-stop-screensaver \
        --vo=vdpau --hwdec=vdpau \
        --loop-file --no-audio --no-osc --no-osd-bar -wid %WID --no-input-default-bindings \
        "$2" &
    PIDs+=($!)
  }

  while read p; do
    [[ $(ps -p "$p" -o comm=) == "xwinwrap" ]] && kill -9 "$p";
  done < $PIDFILE

  sleep 0.5

  for i in $(xrandr -q | grep ' connected' | grep -oP '\d+x\d+\+\d+\+\d+')
  do
    screen "$i" "$1"
  done

  printf "%s\n" "$\{PIDs[@]}" > $PIDFILE
''