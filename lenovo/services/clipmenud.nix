{ writeShellScript
, lib
, findutils
, coreutils-full
, clipmenu
, procps
}:

writeShellScript "clipmenud" ''
  PATH=${lib.makeBinPath [ clipmenu coreutils-full findutils procps ]}
  export XAUTHORITY="$(find /tmp -maxdepth 1 -name 'xauth_*' | head -n 1)"
  if [ -z "$XAUTHORITY" ]; then
    echo "XAUTHORITY could not be found" >&2
    exit 1
  fi
  clipmenud &
''