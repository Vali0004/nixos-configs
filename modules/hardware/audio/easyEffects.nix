{ config, lib, pkgs, ... }:

{
  options.programs.easyeffects = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable EasyEffects, a noise suppression tool";
    };
  };

  config = lib.mkIf config.programs.easyeffects.enable {
    environment.systemPackages = [ pkgs.easyeffects ];

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
  };
}