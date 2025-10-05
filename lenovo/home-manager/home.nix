{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
  manage-startup-applications = pkgs.callPackage ./manage-startup-applications.nix {};
in {
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.vali = {
    imports = [
      programs/alacritty.nix
      programs/dconf.nix
      programs/fastfetch.nix
      programs/git.nix
      #programs/rofi.nix
      programs/vscode.nix
      programs/zsh.nix
      services/dunst.nix
      windowManager/sway.nix
    ];

    home = {
      file.".config/xwinwrap/wallpaper.gif".source = ./wallpaper.gif;
      stateVersion = "25.05";
    };

    gtk = {
      enable = true;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
    };

    nixpkgs.config.allowUnfree = true;
  };
}
