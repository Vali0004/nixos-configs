{ config
, ... }:

{
  age.identityPaths = [
    "/etc/ssh/ssh_host_rsa_key"
    "/etc/ssh/ssh_host_ed25519_key"
    "/home/vali/.ssh/nixos_main"
  ];
  age.secrets = {
    nix-netrc = {
      file = ../../../secrets/nix-netrc.age;
      owner = "vali";
      group = "root";
    };
    network-secrets.file = ../../../secrets/network-secrets.age;
    zipline-upload-headers = {
      file = ../../../secrets/zipline-upload-headers.age;
      owner = "vali";
      group = "wheel";
    };
    wireguard-private-yutsu = {
      file = ../../../secrets/wireguard-private-yutsu.age;
      owner = "root";
      group = "root";
    };
  };

  #
  # Used for Git
  #
  # This allows flakes to pull in private repos, otherwise
  # some hacky stuff is needed.
  environment.etc."nix/netrc" = {
    user = "vali";
    group = "root";
    source = config.age.secrets.nix-netrc.path;
  };
}