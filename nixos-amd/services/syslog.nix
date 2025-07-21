{ config, lib, pkgs, ... }:

{
  services.syslog-ng = {
    enable = true;
    extraConfig = ''
      source src {
        udp(ip(0.0.0.0) port(6666));
      };

      destination shitzenlog { file("/var/log/shitzen-nixos.log"); };

      log {
        source(src);
        destination(shitzenlog);
      };
    '';
  };
}
