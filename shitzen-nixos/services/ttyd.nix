{ config, pkgs, ... }:

{
  services.ttyd = {
    enable = true;
    enableIPv6 = true;
    entrypoint = [ "${pkgs.shadow}/bin/login" ];
    port = 7681;
    writeable = true;
  };
}