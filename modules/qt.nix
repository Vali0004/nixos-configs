{ config, lib, ... }:

{
  qt = lib.mkIf config.qt.enable {
    platformTheme = "lxqt";
    style = "adwaita-dark";
  };
}