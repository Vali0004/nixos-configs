{ lib
, writeShellScript
, bc
, gawk
, procps
}:

writeShellScript "memory" ''
  PATH=${lib.makeBinPath [ bc gawk procps ]}

  read -r mem_total mem_used <<< $(free -b | awk '/^Mem:/ { print $2, $3 }')
  used_gib=$(echo "scale=2; $mem_used / 1073741824" | bc)
  percent=$(printf "%.0f" $(echo "$mem_used / $mem_total * 100" | bc -l))

  printf "^d^ %sGiB (%s%%)^d^" "$used_gib" "$percent"
''
