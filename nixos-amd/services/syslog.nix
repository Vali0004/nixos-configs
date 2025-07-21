{ config, lib, pkgs, ... }:

{
  services.syslog-ng = {
    enable = true;
    extraConfig = ''
      source src {
        udp(ip(10.0.0.244) port(6666));
      };

      destination shitzenlog { file("/var/log/shitzen-nixos.log"); };

      log {
        source(src);
        destination(shitzenlog);
      };
    '';
  };
}
