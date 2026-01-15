let
  ssh_keys = import ../ssh_keys_personal.nix;
  ajaxnetworks-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPJ20NST8s2UjWLOgkq7xpw3LXaim1r6KoW20TPa5nh";
  nixos-amd = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7r7kh+QoV9s5ePtVZIIQzFlfECt7MgshAhVWGWiwXG";
  nixos-hass = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgzGChBKyMJx56Qb5Jl+YLs/0p3PzyQsysEDTiDqMQo";
  shitzen-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7yG4ibfAZyxS6IOyXcovlFdLTN3N8dYvQIv5OqgMM1";
  router-vps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3Fk+n0k2+ZsQMo6VCiVPIW1RErbLcLMcCuHyE+e3Mc";
  router-vps-v2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3adP9Ttlij+oey6tIuWExveeu2+MGJNWv6soaG/JOl";
  lenovo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEprfi4ob/fNLFZiYtyXgW0hRGPtrBZIZkNFM74vrJu";
  keys = ssh_keys ++ [
    shitzen-nixos
  ];
in {
  "cleclerc-nanitehosting-com.age".publicKeys = keys;
  "do-not-reply-fuckk-lol.age".publicKeys = keys;
  "git-kursu-dev-db.age".publicKeys = keys;
  "hydra-github-token.age".publicKeys = keys;
  "hydra-runner-ajax-github-token.age".publicKeys = keys ++ [
    ajaxnetworks-nixos
  ];
  "kavita.age".publicKeys = keys;
  "matrix.age".publicKeys = keys;
  "network-secrets.age".publicKeys = ssh_keys ++ [
    lenovo
    nixos-amd
    nixos-hass
  ];
  "nextcloud-admin-password.age".publicKeys = keys;
  "nix-netrc.age".publicKeys = keys ++ [
    ajaxnetworks-nixos
    lenovo
    nixos-amd
  ];
  "oauth2.age".publicKeys = keys;
  "oauth2-proxy.age".publicKeys = keys;
  "prowlarr-api.age".publicKeys = keys;
  "radarr-api.age".publicKeys = keys;
  "sogo-db-password.age".publicKeys = keys;
  "sonarr-api.age".publicKeys = keys;
  "vali-fuckk-lol.age".publicKeys = keys;
  "whcms-db-pass.age".publicKeys = keys;
  "wireguard.age".publicKeys = keys;
  "wireguard-server.age".publicKeys = ssh_keys ++ [
    router-vps
    router-vps-v2
  ];
  "zipline-upload-headers.age".publicKeys = ssh_keys ++ [
    lenovo
    nixos-amd
  ];
  "zipline.age".publicKeys = keys;
}