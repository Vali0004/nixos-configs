{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
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
      #programs/waybar.nix
      programs/zsh.nix
      services/clipmenu.nix
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

    xdg.mimeApps = let
      applications = {
        "x-scheme-handler/osu" = "osuwinello-url-handler.desktop";
        "application/x-osu-skin-archive" = "osuwinello-file-extensions-handler.desktop";
        "application/x-osu-replay" = "osuwinello-file-extensions-handler.desktop";
        "application/x-osu-beatmap-archive" = "osuwinello-file-extensions-handler.desktop";
      };
    in {
      associations.added = applications;
      defaultApplications = applications;
      enable = true;
    };
  };
}
