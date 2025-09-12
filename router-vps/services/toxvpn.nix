{ config, lib, pkgs, ... }:

{
  services.toxvpn = {
    auto_add_peers = [
      "3e24792c18ab55c59974a356e2195f165e0d967726533818e5ac0361b264ea671d1b3a8ec221" # shitzen
    ];
    enable = true;
    localip = "10.0.127.1";
  };

  systemd.services.toxvpn.serviceConfig.TimeoutStartSec = "infinity";
}