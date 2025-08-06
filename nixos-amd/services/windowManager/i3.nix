{ config, lib, pkgs, ... }:

let
  xwinwrap = pkgs.xwinwrap.overrideDerivation (old: {
    version = "v0.9";
    src = pkgs.fetchFromGitHub {
      owner = "Vali0004";
      repo = "xwinwrap";
      rev = "373426eb95ca62dedad3d77833ccf649f98f489b";
      hash = "sha256-przCOyureolbPLqy80DuyQoGeQ7lbGIXeR1z26DvN/E=";
    };
  });
  xwinwrap_gif = pkgs.callPackage ./../xwinwrap.nix { inherit xwinwrap; };
  clipmenud = pkgs.callPackage ./../clipmenud.nix {};
in {
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
      gifsicle
      xwinwrap
      polybar-pulseaudio-control
    ];
    #  ${pkgs.feh}/bin/feh --bg-center /home/vali/wallpaper.png
    extraSessionCommands = ''
      ${pkgs.pulseaudio}/bin/pactl set-default-sink "alsa_output.usb-SteelSeries_SteelSeries_Arctis_1_Wireless-00.analog-stereo"
      ${xwinwrap_gif} /home/vali/.config/xwinwrap/wallpaper.gif
      ${clipmenud}
    '';
    package = pkgs.i3;
  };
  services.displayManager.defaultSession = "none+i3";
}
