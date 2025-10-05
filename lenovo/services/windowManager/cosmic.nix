{ config, lib, pkgs, ... }:

{
  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;

  environment.systemPackages = with pkgs; [
    gifsicle # Needed for wallpaper
    xwinwrap # X11 Windows Wrap
  ];

  services.desktopManager.cosmic = {
    enable = true;
    xwayland.enable = true;
  };

  services.xserver.displayManager = {
    lightdm.enable = false;
  };

  services.displayManager.defaultSession = "COSMIC";
}