{ lib
, writeShellScript
, bc
, coreutils
, gawk
, gnugrep
, iproute2
}:

writeShellScript "network" ''
  PATH=${lib.makeBinPath [ bc coreutils gawk gnugrep iproute2 ]}

  iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')

  # If no interface (disconnected), show fallback
  if [ -z "$iface" ] || ! ip link show "$iface" | grep -q "state UP"; then
      printf "^d^ ^c#f38ba8^Disconnected^d^\n"
      exit 0
  fi

  ip=$(ip addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)

  # If no IP assigned, fallback too
  if [ -z "$ip" ]; then
      printf "^d^ ^c#f38ba8^No IP^d^\n"
      exit 0
  fi

  rx1=$(cat /sys/class/net/$iface/statistics/rx_bytes)
  tx1=$(cat /sys/class/net/$iface/statistics/tx_bytes)
  sleep 1
  rx2=$(cat /sys/class/net/$iface/statistics/rx_bytes)
  tx2=$(cat /sys/class/net/$iface/statistics/tx_bytes)

  rx_rate=$(echo "scale=1; ($rx2 - $rx1) * 8 / 1000000" | bc)
  tx_rate=$(echo "scale=1; ($tx2 - $tx1) * 8 / 1000000" | bc)

  rx_fmt=$(printf "%4.1f" "$rx_rate")
  tx_fmt=$(printf "%4.1f" "$tx_rate")

  printf "^d^ ↓%s Mbit/s ↑%s Mbit/s   ^c#7f849c^%s^d^\n" "$rx_fmt" "$tx_fmt" "$ip"
''
