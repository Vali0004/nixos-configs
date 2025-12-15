{
  networking.firewall.allowedTCPPorts = [
    9001
    1880
  ];

  services.tor = {
    enable = true;
    openFirewall = true;
    relay.enable = false;
    settings = {
      ContactInfo = "vali@fuckk.lol";
      Nickname = "vali";
      ORPort = 9001;
      # Hidden service — map onion:80 -> local 192.168.100.2:1880
      HiddenServiceDir = "/var/lib/tor/hidden_service";
      HiddenServicePort = "80 192.168.100.2:1880";
    };
  };

  services.nginx.virtualHosts."ajaxvpn.localnet" = {
    enableACME = false;
    forceSSL = false;
    listen = [{ addr = "192.168.100.2"; port = 1880; }];
    root = "/data/services/web/ajaxvpn-org-onion";
    locations."/" = {
      index = "index.html";
    };
  };
}