{ config
, ... }:

{
  age.identityPaths = [
    "/etc/ssh/ssh_host_rsa_key"
    "/etc/ssh/ssh_host_ed25519_key"
    "/home/vali/.ssh/nixos_main"
  ];
  age.secrets = {
    network-secrets = {
<<<<<<<< Updated upstream:machines/house/03-home-assistant-localnet/programs/agenix.nix
      file = ../../../../secrets/network-secrets.age;
========
      file = ../../../../../secrets/network-secrets.age;
>>>>>>>> Stashed changes:machines/home/house/03-home-assistant-localnet/modules/agenix.nix
      owner = "root";
      group = "wpa_supplicant";
      mode = "0444";
    };
  };
}