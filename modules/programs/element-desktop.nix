{ config, lib, pkgs, ... }:

{
  options.programs.element-desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to Element Desktop (matrix client).";
    };
  };

  config = lib.mkIf config.programs.element-desktop.enable {
    xdg.mime.addedAssociations = {
      "x-scheme-handler/element" = "element-desktop.desktop";
      "x-scheme-handler/io.element.desktop" = "element-desktop.desktop";
    };

    environment.systemPackages = [ pkgs.element-desktop ];
  };
}
