{ config
, lib
, pkgs
, ... }:

{
  config = lib.mkIf (config.programs.google-chrome.enable or false) {
    xdg.mime = {
      addedAssociations = {
        "x-scheme-handler/ftp" = "com.google.Chrome.desktop";
        "x-scheme-handler/http" = "com.google.Chrome.desktop";
        "x-scheme-handler/https" = "com.google.Chrome.desktop";
      };
      defaultApplications = {
        "application/xhtml+xml" = "com.google.Chrome.desktop";
        "text/html" = "com.google.Chrome.desktop";
        "text/xml" = "com.google.Chrome.desktop";
      };
    };
  };
}