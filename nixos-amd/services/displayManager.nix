{ config, lib, pkgs, ... }:

let
  sddm-theme = pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
  };
in {
  services.xserver.displayManager = {
    lightdm = {
      enable = false;
      background = /home/vali/wallpaper.png;
      extraConfig = ''
        user-background = false
      '';
      greeters.gtk = {
        theme.name = "Noridc-darker";
      };
    };
    setupCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --newmode "2560x1440_240.00" 1442.50 2560 2800 3088 3616 1440 1443 1448 1663 -hsync +vsync
      ${pkgs.xorg.xrandr}/bin/xrandr --addmode DP-2 "2560x1440_240.00"
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode "2560x1440_240.00"
    '';
  };
  environment.systemPackages = [ sddm-theme ];
  services.displayManager = {
    sddm = {
      enable = true;
      extraPackages = with pkgs.kdePackages; [
        sddm-theme
        sddm-kcm
        qtsvg
        qtmultimedia
        qtvirtualkeyboard
      ];
      package = pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      wayland.enable = false;
    };
  };
}
