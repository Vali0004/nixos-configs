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
    dwmblocks
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
      ${pkgs.xwinwrap-gif}/bin/xwinwrap-gif /home/vali/.config/xwinwrap/wallpaper.gif &
      ${pkgs.dwmblocks}/bin/dwmblocks &
      ${pkgs.brightnessctl}/bin/brightnessctl s 65535
    '';
  };

  services.displayManager.defaultSession = "none+dwm";
}