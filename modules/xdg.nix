{ config, lib, pkgs, ... }:

{
  xdg.mime = {
    addedAssociations = {
      "x-scheme-handler/element" = "element-desktop.desktop";
      "x-scheme-handler/io.element.desktop" = "element-desktop.desktop";
      "x-scheme-handler/ftp" = "com.google.Chrome.desktop";
      "x-scheme-handler/http" = "com.google.Chrome.desktop";
      "x-scheme-handler/https" = "com.google.Chrome.desktop";
      "x-scheme-handler/roblox" = "org.vinegarhq.Sober.desktop";
      "x-scheme-handler/roblox-player" = "org.vinegarhq.Sober.desktop";
      "x-scheme-handler/unityhub" = "unityhub.desktop";
    };
    defaultApplications = {
      "application/zip" = "org.kde.ark.desktop";
      "application/xhtml+xml" = "com.google.Chrome.desktop";
      "text/plain" = "code.desktop";
      "text/html" = "com.google.Chrome.desktop";
      "text/xml" = "com.google.Chrome.desktop";
      "inode/directory" = "nemo.desktop";
    };
  };

  xdg.icons.enable = true;

  xdg.portal = {
    config = {
      common.default = [ "gtk" ];
    };
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = false;
  };
}
