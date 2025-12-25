{ lib
, pkgs
, ... }:

{
  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
    openFirewallDHCP = false;
    openFirewallWebserver = true;
    queryLogDeleter.enable = true;
    settings = {
      dns.upstreams = [
        "8.8.8.8"
        "8.8.4.4"
        "1.1.1.1"
        "1.0.0.1"
        "2001:4860:4860::8888"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
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

  services.nginx = {
    enable = true;
    virtualHosts."pihole.localnet" = {
      addSSL = true;
      enableACME = false;
      forceSSL = false;
      sslCertificate = "/var/lib/localnet/pihole.pem";
      sslCertificateKey = "/var/lib/localnet/pihole.key";
      locations."/" = lib.mkProxy {
        ip = "127.0.0.1";
        port = 9810;
      };
    };
  };

  services.kresd.enable = lib.mkForce false;
  services.kresd.instances = 0;
}