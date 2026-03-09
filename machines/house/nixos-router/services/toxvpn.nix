{
  services.toxvpn = {
    auto_add_peers = [
      "12c662716c206e23c3fbcf297938cfca088a65efe97fd7c79dbe0ceb94674b6a19db11b5dd7f" # router-vps (Upstream)
      "d64b8e72a0ddf0d56f48769fbf863abfa8c975f0dc354a154cf8a93da987d01c4c8e3b49345f" # nixos-amd (Desktop)
      "2f4a1de15bde02ebae196bfcd362caa603774ce21fb1461c984966e466544a59946668888fc9" # nas (cleverca22)
      "dd51f5f444b63c9c6d58ecf0637ce4c161fe776c86dc717b2e209bc686e56a5d2227dfee1338" # amd-nixos (cleverca22)
    ];
    enable = true;
    port = 3344;
    localip = "10.192.0.4";
  };

  systemd.services.toxvpn.serviceConfig.TimeoutStartSec = "infinity";
}