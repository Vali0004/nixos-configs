{ config, lib, pkgs, ... }:

{
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      i3-auto-layout
      i3status
      (polybar.override {
        alsaSupport = true;
        pulseSupport = true;
        iwSupport = true;
        i3Support = true;
      })
      polybar-pulseaudio-control
    ];
    extraSessionCommands = ''
      ${pkgs.pulseaudio}/bin/pactl set-default-sink "alsa_output.usb-SteelSeries_SteelSeries_Arctis_1_Wireless-00.analog-stereo"
      ${pkgs.feh}/bin/feh --bg-center /home/vali/wallpaper.png
    '';
    package = pkgs.i3;
  };
}
