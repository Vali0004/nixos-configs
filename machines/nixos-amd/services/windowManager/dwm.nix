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
    # X Window Wrap
    xwinwrap
    xwinwrap-gif
    # X Do Tool
    xdotool
  ];

  services.xserver.windowManager.dwm = {
    enable = true;
    extraSessionCommands = ''
      ${pkgs.pipewire}/bin/pw-metadata -n settings 0 default.audio.sink alsa_output.usb-Sony_INZONE_H9_II-00.analog-stereo
      ${pkgs.xwinwrap-gif}/bin/xwinwrap-gif /home/vali/.config/xwinwrap/wallpaper.gif &
      ${pkgs.dwmblocks}/bin/dwmblocks &
      ${pkgs.manage-gnome-calculator} &
    '';
  };

  services.displayManager.defaultSession = "none+dwm";
}