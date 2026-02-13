{ config
, lib
, pkgs
, ... }:

let
  cfg = config.router;
in {
  networking.firewall.interfaces.${cfg.bridgeInterface} = {
    allowedTCPPorts = [
      53 # DNS
      9810 # PiHole
    ];
    allowedUDPPorts = [
      53 # DNS
    ];
  };

  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = false;
    openFirewallDHCP = false;
    openFirewallWebserver = false;
    queryLogDeleter.enable = true;
    useDnsmasqConfig = true;
    settings = {
      dns = {
        expandHosts = true;
        upstreams = [
          "8.8.8.8"
          "8.8.4.4"
          "1.1.1.1"
          "1.0.0.1"
          "2001:4860:4860::8888"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
      };
      ntp = {
        ipv4.active = true;
        ipv6.active = true;
        sync.active = true;
      };
      misc.dnsmasq_lines = [
        "local=/localnet/"
        "domain=localnet"
        "expand-hosts"
        "addn-hosts=/etc/hosts"
      ];
      webserver = {
        domain = "0.0.0.0";
        port = "9810";
        paths.webroot = "${pkgs.pihole-web}/share/";
        paths.webhome = "/";
        tls.cert = "/var/lib/pihole/tls.pem";
      };
    };
  };

  systemd.services.pihole-ftl.serviceConfig.ReadWritePaths = [
    "/var/lib/misc"
  ];

  services.nginx.virtualHosts."pihole.localnet" = {
    forceSSL = false;
    locations."/" = lib.mkProxy {
      port = 9810;
    };
  };

  services.nginx.virtualHosts."pihole-failover.localnet" = {
    forceSSL = false;
    locations."/" = lib.mkProxy {
      ip = "10.0.0.2";
      port = 9810;
    };
  };

  services.kresd.enable = lib.mkForce false;
  services.kresd.instances = 0;
}