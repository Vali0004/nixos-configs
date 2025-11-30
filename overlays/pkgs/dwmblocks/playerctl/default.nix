{ lib
, writeShellScript
, gnused
, playerctl
}:

writeShellScript "playerctl" ''
  PATH=${lib.makeBinPath [ playerctl gnused ]}

  player_status=$(playerctl status 2> /dev/null)

  if [ "$player_status" = "Playing" ]; then
      output="$(playerctl metadata artist) - $(playerctl metadata title) "
  elif [ "$player_status" = "Paused" ]; then
      output="$(playerctl metadata artist) - $(playerctl metadata title) "
  else
      output="No Source"
  fi

  # Trim and truncate trailing space
  if [ ''${#output} -gt 30 ]; then
    output_trimmed="''${output:0:27}"
    output_trimmed="$(echo "$output_trimmed" | sed 's/[[:space:]]*$//')..."
  else
    output_trimmed="$output"
  fi

  printf "^d^ %s" "$output_trimmed"
''
