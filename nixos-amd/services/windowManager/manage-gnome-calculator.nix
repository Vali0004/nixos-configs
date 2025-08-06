{ lib
, writeShellScript
, coreutils # sleep
, dwm # dwm-msg
, xdotool
}:

writeShellScript "manage-gnome-calculator" ''
  PATH=${lib.makeBinPath [ xdotool dwm coreutils ]}
  LOCKFILE="/tmp/manage-gnome-calculator.pid"

  if [ -e "$LOCKFILE" ] && kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
    echo "Already running (PID: $(cat "$LOCKFILE"))"
    exit 0
  fi

  echo $$ > "$LOCKFILE"
  trap 'rm -f "$LOCKFILE"' EXIT

  declare -A handled_windows

  while true; do
    mapfile -t windows < <(xdotool search --class gnome-calculator 2>/dev/null)

    for win_id in "''${windows[@]}"; do
      if [[ -n "''${handled_windows[$win_id]}" ]]; then
        continue
      fi

      # Focus window for dwm-msg togglefloating
      xdotool windowactivate "$win_id"
      sleep 0.1

      # Toggle floating
      dwm-msg run_command togglefloating

      # Move and resize
      xdotool windowmove "$win_id" 200 150
      xdotool windowsize "$win_id" 400 616

      # Focus again
      xdotool windowactivate "$win_id"

      handled_windows[$win_id]=1
      echo "Managed gnome-calculator window $win_id"
    done

    sleep 1
  done
''
