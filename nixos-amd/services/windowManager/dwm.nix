{ config, lib, pkgs, ... }:

let
  dwmblocks = ((pkgs.dwmblocks.override {
    conf = ./dwmblocks-config.h;
  }).overrideAttrs {
    src = pkgs.fetchFromGitHub {
      owner = "nimaaskarian";
      repo = "dwmblocks-statuscmd-multithread";
      rev = "6700e322431b99ffc9a74b311610ecc0bc5b460a";
      hash = "sha256-TfPomjT/Z4Ypzl5P5VcVccmPaY8yosJmMLHrGBA6Ycg=";
    };
  });
  dwm = with pkgs; pkgs.dwm.overrideAttrs(old: {
    buildInputs = old.buildInputs ++ [ yajl ];
    src = /home/vali/development/dwm;
    #pkgs.fetchFromGitHub {
    #  owner = "Vali0004";
    #  repo = "dwm-fork";
    #  rev = "4cf2d04feade6e1a139b4fbe2ea16fa6d9f7290a";
    #  hash = "sha256-DjSz01jwFCXfxVxz0ITDn8vEuxE1rAjTiAvdcVGtMyc=";
    #};
  });
  clipmenu = pkgs.callPackage ./../clipmenu.nix {};
  dwmblocks-cpu = pkgs.callPackage ./dwmblocks-cpu.nix {};
  dwmblocks-memory = pkgs.callPackage ./dwmblocks-memory.nix {};
  dwmblocks-network = pkgs.callPackage ./dwmblocks-network.nix {};
  dwmblocks-playerctl = pkgs.callPackage ./dwmblocks-playerctl.nix {};
  manage-gnome-calculator = pkgs.callPackage ./manage-gnome-calculator.nix { dwm = dwm; };
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
in {
  environment.etc = {
    "dwm/blocks/scripts/cpu".source = dwmblocks-cpu;
    "dwm/blocks/scripts/memory".source = dwmblocks-memory;
    "dwm/blocks/scripts/network".source = dwmblocks-network;
    "dwm/blocks/scripts/playerctl".source = dwmblocks-playerctl;
  };
  environment.systemPackages = with pkgs; [
    gifsicle # Needed for wallpaper
    dwmblocks # dwm status
    libnotify # dwm ipc
    xwinwrap
  ];
  services.xserver.windowManager.dwm = {
    enable = true;
    extraSessionCommands = ''
      ${pkgs.pulseaudio}/bin/pactl set-default-sink "alsa_output.usb-SteelSeries_SteelSeries_Arctis_1_Wireless-00.analog-stereo"
      ${xwinwrap_gif} /home/vali/.config/xwinwrap/wallpaper.gif &
      ${dwmblocks}/bin/dwmblocks &
      ${manage-gnome-calculator} &
      ${clipmenu}
    '';
    package = dwm;
  };
  services.displayManager.defaultSession = "none+dwm";
}