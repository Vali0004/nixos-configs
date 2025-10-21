{ config, lib, pkgs, ... }:

{
  options.gtk = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to Gtk support.";
    };
  };

  config = lib.mkIf config.gtk.enable {
    environment.systemPackages = [ pkgs.gtk3 ];

    xdg.portal = {
      config.common.default = [ "gtk" ];
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}