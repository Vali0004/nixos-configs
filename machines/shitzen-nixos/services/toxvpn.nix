{
  services.toxvpn = {
    auto_add_peers = [
      "12c662716c206e23c3fbcf297938cfca088a65efe97fd7c79dbe0ceb94674b6a19db11b5dd7f" # router-vps (Upstream)
      "d64b8e72a0ddf0d56f48769fbf863abfa8c975f0dc354a154cf8a93da987d01c4c8e3b49345f" # nixos-amd (Desktop)
    ];
    enable = true;
    localip = "10.192.0.2";
  };

  systemd.services.toxvpn.serviceConfig.TimeoutStartSec = "infinity";
}