{ writeScriptBin
, lib
, coreutils
, gnugrep
, mpv
, procps
, xrandr
, xwinwrap
, bash
}:

writeScriptBin "xwinwrap-gif" ''
  #!${bash}/bin/bash
  set -euo pipefail

  PATH=${lib.makeBinPath [ coreutils gnugrep mpv procps xrandr xwinwrap ]}

  if [ $# -ne 1 ]; then
    echo "Usage: $0 image.gif" >&2
    exit 1
  fi

  GIF="$1"
  PIDDIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"
  PIDFILE="$PIDDIR/xwinwrap-gif.pid"
  mkdir -p "$PIDDIR"

  declare -a PIDs=()

  screen() {
    local geom="$1"
    xwinwrap -ov -ni -g "$geom" -- \
      mpv --fullscreen \
        --no-stop-screensaver \
        --loop-file=inf \
        --no-audio --no-osc --no-osd-bar --no-input-default-bindings \
        --vo=gpu --hwdec=no \
        -wid %WID \
        "$GIF" &
    PIDs+=("$!")
  }

  # Kill previous xwinwrap instances we started
  if [[ -f "$PIDFILE" ]]; then
    while IFS= read -r p; do
      [[ -z "$p" ]] && continue
      if ps -p "$p" -o comm= 2>/dev/null | grep -qx "xwinwrap"; then
        kill "$p" 2>/dev/null || true
      fi
    done < "$PIDFILE"
    rm -f "$PIDFILE"
  fi

  sleep 0.2

  # One xwinwrap per connected output geometry
  while IFS= read -r geom; do
    screen "$geom"
  done < <(xrandr -q | grep ' connected' | grep -oP '\d+x\d+\+\d+\+\d+')

  printf "%s\n" "''${PIDs[@]}" > "$PIDFILE"
''