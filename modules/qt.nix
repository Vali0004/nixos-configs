{ config, lib, ... }:

{
  qt = lib.mkIf config.qt.enable {
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}