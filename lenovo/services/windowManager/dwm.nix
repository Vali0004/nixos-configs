{ pkgs, ... }:

{
  imports = [
    ../.../modules/dwmblocks.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
      dwmblocks = super.dwmblocks.override {
        conf = ./dwmblocks-config.h;
      };
    })
  ];

  environment.systemPackages = with pkgs; [
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