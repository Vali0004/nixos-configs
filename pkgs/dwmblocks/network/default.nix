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

  if [ -z "$iface" ] || ! ip link show "$iface" | grep -q "state UP"; then
    printf "^d^ ^c#f38ba8^Disconnected^d^"
    exit 0
  fi

  ip=$(ip addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)

  if [ -z "$ip" ]; then
    printf "^d^ ^c#f38ba8^No IP^d^"
    exit 0
  fi

  printf "^d^ ^c#7f849c^%s^d^" "$ip"
''
