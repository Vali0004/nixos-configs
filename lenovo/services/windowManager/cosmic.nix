{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gifsicle # Needed for wallpaper
    xwinwrap # X11 Windows Wrap
  ];

  services.desktopManager.cosmic = {
    enable = true;
    xwayland.enable = true;
  };
}