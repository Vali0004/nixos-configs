{ config
, ... }:

{
  age.identityPaths = [
    "/etc/ssh"
    "/home/vali/.ssh"
  ];
  age.secrets = {
    nix-netrc.file = ../../../secrets/nix-netrc.age;
    network-secrets.file = ../../../secrets/network-secrets.age;
    zipline-upload-headers = {
      file = ../../../secrets/zipline-upload-headers.age;
      owner = "root";
      group = "wheel";
    };
  };

  #
  # Used for Git
  #
  # This allows flakes to pull in private repos, otherwise
  # some hacky stuff is needed.
  environment.etc."nix/netrc" = {
    user = "root";
    source = config.age.secrets.nix-netrc.path;
  };
}