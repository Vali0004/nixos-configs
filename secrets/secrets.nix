let
  ssh_keys = import ../ssh_keys_personal.nix;
  nixos-amd = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7r7kh+QoV9s5ePtVZIIQzFlfECt7MgshAhVWGWiwXG";
  shitzen-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7yG4ibfAZyxS6IOyXcovlFdLTN3N8dYvQIv5OqgMM1";
  router-vps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3Fk+n0k2+ZsQMo6VCiVPIW1RErbLcLMcCuHyE+e3Mc";
  router-vps-v2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3adP9Ttlij+oey6tIuWExveeu2+MGJNWv6soaG/JOl";
  keys = ssh_keys ++ [
    shitzen-nixos
  ];
in {
  "cleclerc-mail-nanitehosting-com.age".publicKeys = keys;
  "do-not-reply-fuckk-lol.age".publicKeys = keys;
  "git-fuckk-lol-db.age".publicKeys = keys;
  "hydra-github-token.age".publicKeys = keys;
  "hydra-runner-ajax-github-token.age".publicKeys = keys;
  "kavita.age".publicKeys = keys;
  "maddy-mail-fuckk-lol.age".publicKeys = keys;
  "matrix.age".publicKeys = keys;
  "network-secrets.age".publicKeys = ssh_keys ++ [
    nixos-amd
  ];
  "nextcloud-admin-password.age".publicKeys = keys;
  "nix-netrc.age".publicKeys = keys ++ [
    nixos-amd
  ];
  "oauth2.age".publicKeys = keys;
  "oauth2-proxy.age".publicKeys = keys;
  "prowlarr-api.age".publicKeys = keys;
  "proxy-mail-fuckk-lol.age".publicKeys = keys;
  "radarr-api.age".publicKeys = keys;
  "sonarr-api.age".publicKeys = keys;
  "vali-mail-fuckk-lol.age".publicKeys = keys;
  "wireguard.age".publicKeys = keys;
  "wireguard-server.age".publicKeys = ssh_keys ++ [
    router-vps
    router-vps-v2
  ];
  "zipline-upload-headers.age".publicKeys = ssh_keys ++ [
    nixos-amd
  ];
  "zipline.age".publicKeys = keys;
}