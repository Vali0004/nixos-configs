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
      programs/zsh.nix
      services/dunst.nix
      windowManager/i3.nix
      services/polybar.nix
    ];

    home = {
      stateVersion = "25.05";
    };

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
    };

    nixpkgs.config.allowUnfree = true;

    services.clipmenu = {
      enable = true;
      launcher = "rofi";
    };

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