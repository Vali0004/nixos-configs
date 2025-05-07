{ config, lib, pkgs, ... }:

{
  systemd.user.services.easyeffects = {
    enable = true;
    after = [ "graphical-session-pre.target" ];
    description = "EasyEffects Daemon";
    partOf = [ "graphical-session.target" "pipewire.service" ];
    requires = [ "dbus.service" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
      ExecStop = "${pkgs.easyeffects}/bin/easyeffects --quit";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}