{ lib
, writeShellScript
, upower
, coreutils
, gawk
, gnugrep
, gnused
}:

writeShellScript "battery-status" ''
  PATH=${lib.makeBinPath [ upower coreutils gawk gnugrep gnused ]}

  # Get battery device (first BAT* found by upower)
  battery=$(upower -e | grep 'BAT' | head -n1)

  if [ -z "$battery" ]; then
    output="No Battery"
  else
    percent=$(upower -i "$battery" | grep -E "percentage" | awk '{print $2}' | tr -d '%')
    state=$(upower -i "$battery" | grep -E "state" | awk '{print $2}')

    # Choose icon
    if [ "$state" = "charging" ]; then
      icon=""
    elif [ "$percent" -ge 80 ]; then
      icon=""
    elif [ "$percent" -ge 60 ]; then
      icon=""
    elif [ "$percent" -ge 40 ]; then
      icon=""
    elif [ "$percent" -ge 20 ]; then
      icon=""
    else
      icon=""
    fi

    output="^c#94e2d5^$icon"^d^ $percent%"
  fi

  # Trim and truncate trailing space
  if [ ''${#output} -gt 30 ]; then
    output_trimmed="''${output:0:27}"
    output_trimmed="$(echo "$output_trimmed" | sed 's/[[:space:]]*$//')..."
  else
    output_trimmed="$output"
  fi

  printf "%s" "$output_trimmed"
''