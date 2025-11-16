let
  mkProxy = import ../../modules/mkproxy.nix {};
in {
  networking.firewall.allowedTCPPorts = [
    9001
    8080
  ];

  services.tor = {
    enable = true;
    openFirewall = true;
    relay.enable = false;
    settings = {
      ContactInfo = "vali@fuckk.lol";
      Nickname = "vali";
      ORPort = 9001;
      # Hidden service — map onion:80 -> local 192.168.100.2:8080
      HiddenServiceDir = "/var/lib/tor/hidden_service";
      HiddenServicePort = "80 192.168.100.2:8080";
    };
  };

  services.nginx.virtualHosts."ajaxvpn.localnet" = {
    enableACME = false;
    forceSSL = false;
    listen = [{ addr = "192.168.100.2"; port = 8080; }];
    root = "/data/services/web/ajaxvpn-org-onion";
    locations."/" = {
      index = "index.html";
    };
  };
}