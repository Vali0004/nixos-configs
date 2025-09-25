{ config, lib, pkgs, ... }:

{
  imports = [
    ./../../../modules/dwmblocks.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
      dwmblocks = super.dwmblocks.override {
        conf = ./dwmblocks-config.h;
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    gifsicle # Needed for wallpaper
    dwmblocks # dwm status
    libnotify # dwm ipc
    xwinwrap # X11 Windows Wrap
  ];

  services.xserver.windowManager.dwm = {
    enable = true;
    extraSessionCommands = ''
      ${pkgs.xwinwrap-gif} /home/vali/.config/xwinwrap/wallpaper.gif &
      ${pkgs.dwmblocks}/bin/dwmblocks &
      ${pkgs.manage-gnome-calculator} &
    '';
  };

  services.displayManager.defaultSession = "none+dwm";
}