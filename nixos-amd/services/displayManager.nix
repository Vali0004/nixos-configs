{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager = {
    lightdm = {
      enable = true;
      background = /home/vali/wallpaper.png;
      extraConfig = ''
        user-background = false
      '';
      greeters.gtk = {
        theme.name = "Noridc-darker";
      };
    };
    setupCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --newmode "2560x1440_239.97"  1442.50  2560 2800 3088 3616  1440 1443 1448 1663 -hsync +vsyn
      ${pkgs.xorg.xrandr}/bin/xrandr --addmode DP-3 2560x1440_239.97
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-3 --mode 2560x1440_239.97
      ${pkgs.i3-auto-layout}/bin/i3-auto-layout &
    '';
  };
  services.displayManager = {
    defaultSession = "none+i3";
    #sddm = {
    #  enable = true;
    #  wayland.enable = true;
    #  theme = "Noridc-darker";
    #};
  };
}
