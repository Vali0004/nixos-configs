let
  ssh_keys = import ../ssh_keys_personal.nix;
  machines = [
    # shitzen-nixos
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7yG4ibfAZyxS6IOyXcovlFdLTN3N8dYvQIv5OqgMM1"
    # router-vps
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3Fk+n0k2+ZsQMo6VCiVPIW1RErbLcLMcCuHyE+e3Mc"
  ];
  keys = machines ++ ssh_keys;
in {
  "convoy.age".publicKeys = keys;
  "cleclerc-mail-nanitehosting-com.age".publicKeys = keys;
  "do-not-reply-fuckk-lol.age".publicKeys = keys;
  "git-fuckk-lol-db.age".publicKeys = keys;
  "hydra-github-token.age".publicKeys = keys;
  "hydra-runner-ajax-github-token.age".publicKeys = keys;
  "kavita.age".publicKeys = keys;
  "maddy-mail-fuckk-lol.age".publicKeys = keys;
  "matrix.age".publicKeys = keys;
  "nix-netrc.age".publicKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7yG4ibfAZyxS6IOyXcovlFdLTN3N8dYvQIv5OqgMM1" ] ++ ssh_keys;
  "oauth2.age".publicKeys = keys;
  "oauth2-proxy.age".publicKeys = keys;
  "pnp-api.age".publicKeys = keys;
  "pnp-loader.age".publicKeys = keys;
  "prowlarr-api.age".publicKeys = keys;
  "pterodactyl.age".publicKeys = keys;
  "proxy-mail-fuckk-lol.age".publicKeys = keys;
  "radarr-api.age".publicKeys = keys;
  "sonarr-api.age".publicKeys = keys;
  "shadowsocks.age".publicKeys = keys;
  "vali-mail-fuckk-lol.age".publicKeys = keys;
  "zipline.age".publicKeys = keys;
  "wireguard.age".publicKeys = keys;
  "wireguard-down.age".publicKeys = keys;
  "wireguard-server.age".publicKeys = keys;
}