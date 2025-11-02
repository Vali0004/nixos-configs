{ inputs
, config
, pkgs
, ... }:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
    sha256 = "0h33b93cr2riwd987ii5xl28mac590fm2041c5pcz0kdad3yll4s";
  };
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
      programs/rofi.nix
      programs/waybar.nix
      programs/zsh.nix
      services/dunst.nix
      windowManager/mango.nix
      inputs.mangowc.hmModules.mango
    ];

    home = {
      file.".config/xwinwrap/wallpaper.gif".source = ./wallpaper.gif;
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