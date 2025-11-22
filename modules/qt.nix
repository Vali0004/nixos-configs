{ config
, lib
, ... }:

{
  qt = lib.mkIf config.qt.enable {
    platformTheme = "qt5ct";
    style = "adwaita-dark";
  };
}