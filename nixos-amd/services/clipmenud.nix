{ config, lib, pkgs, ... }:

{
  systemd.user.services.clipmenud = {
    Unit = {
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [
        "DISPLAY=:0"
        "XAUTHORITY=${config.home.homeDirectory}/.Xauthority"
      ];
    };
  };
}