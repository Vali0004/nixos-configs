{ config
, ... }:

{
  age.identityPaths = [
    "/etc/ssh/ssh_host_rsa_key"
    "/etc/ssh/ssh_host_ed25519_key"
    "/home/vali/.ssh/nixos_main"
  ];
  age.secrets = {
    network-secrets.file = ../../../secrets/network-secrets.age;
  };
}