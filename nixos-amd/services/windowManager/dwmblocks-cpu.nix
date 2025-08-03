{ lib
, writeShellScript
, coreutils
, gnused
, gawk
}:

writeShellScript "cpu" ''
  PATH=${lib.makeBinPath [ coreutils gawk gnused ]}

  PREV_TOTAL=0
  PREV_IDLE=0

  read_cpu() {
    CPU=($(sed -n 's/^cpu\s//p' /proc/stat))
    IDLE=''${CPU[3]}
    TOTAL=0
    for VALUE in "''${CPU[@]}"; do
      TOTAL=$((TOTAL + VALUE))
    done
    echo "$IDLE $TOTAL"
  }

  read1=$(read_cpu)
  sleep 0.5
  read2=$(read_cpu)

  IDLE1=$(echo "$read1" | awk '{print $1}')
  TOTAL1=$(echo "$read1" | awk '{print $2}')
  IDLE2=$(echo "$read2" | awk '{print $1}')
  TOTAL2=$(echo "$read2" | awk '{print $2}')

  DIFF_IDLE=$((IDLE2 - IDLE1))
  DIFF_TOTAL=$((TOTAL2 - TOTAL1))
  DIFF_USAGE=$((100 * (DIFF_TOTAL - DIFF_IDLE) / DIFF_TOTAL))

  if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp)
    TEMP_C=$((TEMP_RAW / 1000))
  else
    TEMP_C="?"
  fi

  printf "^d^ %s (%s °C)" "$DIFF_USAGE" "$TEMP_C"
''
