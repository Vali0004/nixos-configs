{ config
, pkgs
, ... }:

let
  ssh_config = config.environment.etc."ssh/ssh_config".text;
in {
  home-manager.users.vali = {
    imports = [
      programs/alacritty.nix
      programs/fastfetch.nix
      programs/git.nix
      programs/rofi.nix
      programs/vscode.nix
      programs/zsh.nix
      services/dunst.nix
      #services/monado.nix
      #windowManager/i3.nix
      #windowManager/hypr.nix
    ];

    home = {
      file.".config/xwinwrap/wallpaper.gif".source = ./wallpaper.gif;
      file.".config/xwinwrap/wallpaper.png".source = ./wallpaper.png;
      file.".config/syncplay.ini".source = ./syncplay.ini;
      # Fixes Zsh plugin for SSH Hostnames
      file.".ssh/config".text = ssh_config;
      stateVersion = "25.11";
    };

    gtk = {
      enable = true;
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4 = {
        extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };
      };
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