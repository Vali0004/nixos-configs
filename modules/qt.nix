{ config
, lib
, ... }:

{
  qt = lib.mkIf config.qt.enable {
    platformTheme = "gtk2";
    style = "adwaita-dark";
  };
}