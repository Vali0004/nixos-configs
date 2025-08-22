let
  ssh_keys = import ../ssh_keys_personal.nix;
  machines = [
    # shitzen-nixos
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7yG4ibfAZyxS6IOyXcovlFdLTN3N8dYvQIv5OqgMM1"
    # router
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4a7HHWzTJQqAl2b6c/Y5gjZE26dRB0FGoPVeG1d+2Z"
  ];
  keys = machines ++ ssh_keys;
in {
  "convoy.age".publicKeys = keys;
  "cleclerc-mail-nanitehosting-com.age".publicKeys = keys;
  "hydra-github-token.age".publicKeys = keys;
  "oauth2.age".publicKeys = keys;
  "oauth2-proxy.age".publicKeys = keys;
  "pnp-api.age".publicKeys = keys;
  "pnp-loader.age".publicKeys = keys;
  "pterodactyl.age".publicKeys = keys;
  "vali-mail-fuckk-lol.age".publicKeys = keys;
  "zipline.age".publicKeys = keys;
  "wireguard.age".publicKeys = keys;
  "wireguard-down.age".publicKeys = keys;
  "wireguard-server.age".publicKeys = keys;
}