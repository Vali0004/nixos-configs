{
  services.toxvpn = {
    auto_add_peers = [
      
    ];
    enable = true;
    localip = "10.192.0.2";
  };

  systemd.services.toxvpn.serviceConfig.TimeoutStartSec = "infinity";
}