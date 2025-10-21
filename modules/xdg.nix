{ config, lib, pkgs, ... }:

{
  options.xdg = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to XDG Support.";
    };
  };

  config = lib.mkIf config.xdg.enable {
    environment.systemPackages = with pkgs; [
      # XDG GUI Debug Utility
      bustle
      # XDG Debug Utility
      bridge-utils
      # XDG Mime/Desktop utils
      desktop-file-utils
      # XDG
      xdg-launch
      xdg-utils
    ];

    xdg.mime.addedAssociations = {
      "x-scheme-handler/roblox" = "org.vinegarhq.Sober.desktop";
      "x-scheme-handler/roblox-player" = "org.vinegarhq.Sober.desktop";
    };

    xdg.icons.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal
      ];
      xdgOpenUsePortal = false;
    };
  };
}