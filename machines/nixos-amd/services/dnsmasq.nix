{ pkgs
, ... }:

{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      bind-interfaces = true;
      dhcp-option = [
        "option6:dns-server,[2001:4860:4860::8888]"
        "option6:dns-server,[2606:4700:4700::1111]"
      ];
      dhcp-range = [
        "192.168.0.2,192.168.0.254"
        "2001:db8:1::1000,2001:db8:1::2000,64,12h"
        "::,constructor:eth0,ra-stateless,12h"
      ];
      enable-ra = true;
      interface = [
        "eth0"
      ];
      server = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };

  networking = {
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "192.168.0.1";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2001:db8:1::1";
        prefixLength = 64;
      }];
    };
    firewall.extraCommands = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
    '';
  };
}