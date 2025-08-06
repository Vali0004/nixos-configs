{ lib
, writeScriptBin
}:

writeScriptBin "manage-startup-applications" ''
  # Launch apps
  discord &
  Cider &

  discord_done=0
  cider_done=0

  # Loop for max 20 seconds
  for _ in $(seq 1 20); do
    clients=$(dwm-msg get_clients)

    if [ "$discord_done" -eq 0 ]; then
      discord_id=$(echo "$clients" | jq -r '
        .clients[]
        | select(
            (.title | test("Discord$")) and
            (.title | contains("Updater") | not)
          )
        | .client_window_id' | head -n 1)

      if [ -n "$discord_id" ]; then
        dwm-msg run_command tagclient "$discord_id" 8  # tag 4
        discord_done=1
      fi
    fi

    if [ "$cider_done" -eq 0 ]; then
      cider_id=$(echo "$clients" | jq -r '
        .clients[]
        | select(.title == "Cider")
        | .client_window_id' | head -n 1)

      if [ -n "$cider_id" ]; then
        dwm-msg run_command tagclient "$cider_id" 16  # tag 5
        cider_done=1
      fi
    fi

    if [ "$discord_done" -eq 1 ] && [ "$cider_done" -eq 1 ]; then
      break
    fi

    sleep 1
  done
''
