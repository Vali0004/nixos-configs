{ config, lib, pkgs, ... }:

{
  options.programs.google-chrome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to Google Chrome.";
    };
  };

  config = lib.mkIf config.programs.google-chrome.enable {
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
    environment.systemPackages = [ pkgs.google-chrome ];
    nixpkgs.config.allowUnfree = true;
  };
}
