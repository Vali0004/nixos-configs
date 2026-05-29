{ config
, ... }:

{
  networking.firewall.allowedTCPPorts = [
    config.services.syncplay.port
  ];

  services.syncplay = {
    enable = true;
    chat = true;
    passwordFile = config.age.secrets.syncplay.path;
    port = 1337;
    salt = "GNCXTBCQDN";
    statsDBFile = "stats.db";
  };
}