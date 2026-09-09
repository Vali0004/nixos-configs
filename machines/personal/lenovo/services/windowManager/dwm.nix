{ pkgs
, ... }:

let
  dmenu_wrapper = pkgs.writeScriptBin "dmenu" ''
    ${pkgs.rofi}/bin/rofi -dmenu
  '';
in {
  imports = [
    ../../../../../modules/environment/dwmblocks.nix
  ];

  environment.systemPackages = with pkgs; [
    # App launcher
    dmenu_wrapper
    # dwm status
    dwmblocks-laptop
    # Gifsicle, used to split & optimize GIFS
    gifsicle
    # dwm ipc
    libnotify
    # X Window Wrap
    xwinwrap
    xwinwrap-gif
    # X Do Tool
    xdotool
  ];

  services.xserver.windowManager.dwm = {
    enable = true;
    extraSessionCommands = ''
      # Drains battery - look at cheaper alternatives
      #${pkgs.xwinwrap-gif}/bin/xwinwrap-gif /home/vali/.config/xwinwrap/wallpaper.gif &
      ${pkgs.dwmblocks-laptop}/bin/dwmblocks &
      # Possibly look into why brightness defaults to 0 instead of FFFF, look into possibly benefits of a lower brightness in relation to battery life
      # TTE is 5 hours from 70%
      ${pkgs.brightnessctl}/bin/brightnessctl s 65535
    '';
  };

  services.displayManager.defaultSession = "none+dwm";
}