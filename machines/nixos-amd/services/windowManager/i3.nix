{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    # App launcher
    dmenu
  ];
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      # Clipboard Manager
      clipmenu
      # Clipboard Manager (auto-paste)
      clipmenu-paste
      # Gifsicle, used to split & optimize GIFS
      gifsicle
      # i3 Auto Layout
      i3-auto-layout
      # Status
      i3status
      # Menu bar
      (polybar.override {
        alsaSupport = true;
        pulseSupport = true;
        iwSupport = true;
        i3Support = true;
      })
      # Audio control
      polybar-pulseaudio-control
      # App launcher
      rofi
      # X Window Wrap
      xwinwrap
    ];
    extraSessionCommands = ''
      ${pkgs.pulseaudio}/bin/pactl set-default-sink "alsa_output.usb-SteelSeries_SteelSeries_Arctis_1_Wireless-00.analog-stereo"
      ${pkgs.xwinwrap-gif} /home/vali/.config/xwinwrap/wallpaper.gif &
    '';
  };

  services.displayManager.defaultSession = "none+i3";
}
