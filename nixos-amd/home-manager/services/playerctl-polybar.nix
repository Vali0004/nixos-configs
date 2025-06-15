{ lib, playerctl, writeShellScript }:

writeShellScript "pipewire.sh" ''
PATH=${lib.makeBinPath [ playerctl ]}

player_status=$(playerctl status 2> /dev/null)

if [ "$player_status" = "Playing" ]; then
    output="$(playerctl metadata artist) - $(playerctl metadata title) "
elif [ "$player_status" = "Paused" ]; then
    output="$(playerctl metadata artist) - $(playerctl metadata title) "
else
    output="No Source"
fi

if [ ''${#output} -gt 30 ]; then
  output_trimmed="''${output:0:27}..."
else
  output_trimmed="$output"
fi
# Trim to 30 characters max
echo "''${output_trimmed}"
''
