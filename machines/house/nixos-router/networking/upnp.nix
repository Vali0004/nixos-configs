{ config
, ... }:

let
  cfg = config.router;
in {
  networking.firewall.interfaces.${cfg.bridgeInterface} = {
    allowedUDPPorts = [ 1900 5351 ];
    allowedTCPPorts = [ 5000 ];
  };

  services.miniupnpd = {
    enable = true;
    externalInterface = cfg.wanInterface;
    internalIPs = [ cfg.bridgeInterface ];
    natpmp = true;
    upnp = true;
    appendConfig = ''
      secure_mode=yes

      allow 1024-65535 ${cfg.lanSubnet}.0/24 1024-65535
      deny 0-65535 0.0.0.0/0 0-65535
      port=5000

      system_uptime=yes
      uuid=00000000-0000-0000-0000-000000000001
    '';
  };
}