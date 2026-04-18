let
  ssh_keys = import ../ssh_keys_personal.nix;
  nixos-amd = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7r7kh+QoV9s5ePtVZIIQzFlfECt7MgshAhVWGWiwXG";
  home-assistant = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgzGChBKyMJx56Qb5Jl+YLs/0p3PzyQsysEDTiDqMQo";
  shitzen-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7yG4ibfAZyxS6IOyXcovlFdLTN3N8dYvQIv5OqgMM1";
  nas-wg-exitnode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3Fk+n0k2+ZsQMo6VCiVPIW1RErbLcLMcCuHyE+e3Mc";
  lenovo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEprfi4ob/fNLFZiYtyXgW0hRGPtrBZIZkNFM74vrJu";
  nas-mail-exitnode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwxJtftpB9HvA78rG9u7KxfNRP9Z6TX/7mXf5X1G25b";
  keys = ssh_keys ++ [
    shitzen-nixos
  ];
in {
  "cleclerc-nanitehosting-com.age".publicKeys = keys;
  "do-not-reply-kursu-dev.age".publicKeys = keys;
  "git-kursu-dev-db.age".publicKeys = keys;
  "gitea-runner-token.age".publicKeys = keys;
  "grafana-secret.age".publicKeys = keys;
  "hydra-github-token.age".publicKeys = keys;
  "kavita.age".publicKeys = keys;
  "matrix.age".publicKeys = keys;
  "network-secrets.age".publicKeys = ssh_keys ++ [
    lenovo
    nixos-amd
    home-assistant
  ];
  "wireguard-home.age".publicKeys = ssh_keys ++ [
    lenovo
    nixos-amd
  ];
  "wireguard-private-yutsu.age".publicKeys = ssh_keys ++ [
    nixos-amd
  ];
  "nextcloud-admin-password.age".publicKeys = keys;
  "nix-netrc.age".publicKeys = keys ++ [
    lenovo
    nixos-amd
  ];
  "oauth2.age".publicKeys = keys;
  "oauth2-proxy.age".publicKeys = keys;
  "pterodactyl.age".publicKeys = keys;
  "pterodactyl-db.age".publicKeys = keys;
  "prowlarr-api.age".publicKeys = keys;
  "radarr-api.age".publicKeys = keys;
  "sogo-db-password.age".publicKeys = keys;
  "sonarr-api.age".publicKeys = keys;
  "vali-kursu-dev.age".publicKeys = keys;
  "whcms-db-pass.age".publicKeys = keys;
  "wireguard.age".publicKeys = keys;
  "wireguard-server.age".publicKeys = ssh_keys ++ [
    nas-wg-exitnode
  ];
  "wireguard-mail-server.age".publicKeys = ssh_keys ++ [
    nas-mail-exitnode
  ];
  "zipline-upload-headers.age".publicKeys = ssh_keys ++ [
    lenovo
    nixos-amd
  ];
  "zipline.age".publicKeys = keys;
}