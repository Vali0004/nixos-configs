{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
    sha256 = "0m2k94yvplvi9zz3h1gz031r020jw5l35yykqfmqpmvpiqms9m2k";
  };
  manage-startup-applications = pkgs.callPackage ./manage-startup-applications.nix {};
  ssh_config = config.environment.etc."ssh/ssh_config".text;
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
      #programs/waybar.nix
      programs/zsh.nix
      services/dunst.nix
      services/monado.nix
      #services/polybar.nix
      #windowManager/i3.nix
      #windowManager/hypr.nix
    ];

    home = {
      file.".config/xwinwrap/wallpaper.gif".source = ./wallpaper.gif;
      file.".config/syncplay.ini".source = ./syncplay.ini;
      file.".local/share/dwm/autostart.sh".source = "${manage-startup-applications}/bin/manage-startup-applications";
      # Fixes Zsh plugin for SSH Hostnames
      file.".ssh/config".text = ssh_config;
      stateVersion = "25.11";
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
