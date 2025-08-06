{ config, lib, pkgs, ... }:

{
  systemd.user.services.clipmenud = {
    after = [ "graphical-session.target" ];
    description = "Clipboard management daemon";
    enable = true;
    environment = {
      CM_LAUNCHER = "dmenu";
      CM_SYNC_PRIMARY_TO_CLIPBOARD = "1";
      DISPLAY = ":0";
    };
    serviceConfig = {
      EnvironmentFile = "%t/clipmenud-env";
      ExecStartPre = pkgs.writeShellScript "detect-xauthority" ''
        export XAUTHORITY=$(find /tmp -maxdepth 1 -type f -name 'xauth_*' -user "$USER" | head -n 1)
        echo "XAUTHORITY=$XAUTHORITY" > "$XDG_RUNTIME_DIR/clipmenud-env"
      '';
      ExecStart = "${pkgs.clipmenu}/bin/clipmenud";
      Restart = "always";
      RestartSec = 1;
      TimeoutStopSec = 2;
    };
    wantedBy = [ "default.target" ];
  };
}