{ config, ... }:

{
  services.toxvpn = {
    enable = true;
    auto_add_peers = [
      "e0f6bcec21be59c77cf338e3946a766cd17a8e9c40a2b7fe036e7996f3a59554b4ecafdc2df6" # chromeshit
      "dd51f5f444b63c9c6d58ecf0637ce4c161fe776c86dc717b2e209bc686e56a5d2227dfee1338" # clever
    ];
  };

  systemd.services.toxvpn.serviceConfig.TimeoutStartSec = "infinity";
}