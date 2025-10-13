{ config, lib, pkgs, ... }:

{
  options.programs.kde-ark = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to Element Desktop (matrix client).";
    };
  };

  config = lib.mkIf config.programs.kde-ark.enable {
    xdg.mime.defaultApplications."application/zip" = "org.kde.ark.desktop";

    environment.systemPackages = [ pkgs.kdePackages.ark ];
  };
}
