{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {
  imports = [
    (import "${home-manager}/nixos")
  ];
  home-manager.users.vali = {
    imports = [
      programs/alacritty.nix
      programs/fastfetch.nix
      programs/rofi.nix
      programs/vscode.nix
      #programs/waybar.nix
      programs/zsh.nix
      services/clipmenu.nix
      services/dunst.nix
      services/polybar.nix
      windowManager/i3.nix
      #windowManager/hypr.nix
    ];

    home.stateVersion = "25.05";

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
    };

    nixpkgs.config.allowUnfree = true;

    xdg.mimeApps = {
      associations = {
        added = {
          "x-scheme-handler/osu" = "osu.desktop";
        };
      };
      defaultApplications = {
        "x-scheme-handler/osu" = [ "osu.desktop" ];
      };
      enable = true;
    };
  };
}
