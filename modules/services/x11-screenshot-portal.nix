{ pkgs
, ... }:

{
  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-x11-screenshot ];
    config.dwm = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "x11-screenshot" ];
    };
  };

  services.xserver.windowManager.dwm.extraSessionCommands = ''
    export XDG_CURRENT_DESKTOP=dwm
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
  '';
}