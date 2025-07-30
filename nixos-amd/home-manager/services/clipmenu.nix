{ config, lib, ... }:

{
  home.sessionVariables.CM_SYNC_PRIMARY_TO_CLIPBOARD = 1;
  services.clipmenu = {
    enable = true;
    launcher = "dmenu";
  };
}
