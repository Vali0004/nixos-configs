{
  services.toxvpn = {
    auto_add_peers = [
      "ba32f4e9ea7c270bdd284de0c6872c040ffc1809ebe8798eb544a621ce0f98753c4d3cf739d1" # shitzen-nixos
    ];
    enable = true;
    localip = "10.192.0.1";
  };

  systemd.services.toxvpn.serviceConfig.TimeoutStartSec = "infinity";
}