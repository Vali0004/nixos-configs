{ pkgs, ... }:

{
  imports = [
    ../../../../modules/environment/dwmblocks.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
      dwmblocks = super.dwmblocks.override {
        conf = ./dwmblocks-config.h;
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    # Clipboard Manager
    clipmenu
    # Clipboard Manager (auto-paste)
    clipmenu-paste
    # App launcher
    dmenu
    # dwm status
    dwmblocks
    # Gifsicle, used to split & optimize GIFS
    gifsicle
    # dwm ipc
    libnotify
    # Audio control
    pavucontrol
    # X Window Wrap
    xwinwrap
    # X Do Tool
    xdotool
  ];

  services.xserver.windowManager.dwm = {
    enable = true;
    extraSessionCommands = ''
      ${pkgs.pulseaudio}/bin/pactl set-default-sink "alsa_output.usb-SteelSeries_SteelSeries_Arctis_1_Wireless-00.analog-stereo"
      ${pkgs.xwinwrap-gif} /home/vali/.config/xwinwrap/wallpaper.gif &
      ${pkgs.dwmblocks}/bin/dwmblocks &
      ${pkgs.manage-gnome-calculator} &
    '';
  };

  services.displayManager.defaultSession = "none+dwm";
}