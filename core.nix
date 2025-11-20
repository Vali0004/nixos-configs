{ config, pkgs, ... }:

let
  my_keys = import ./ssh_keys_personal.nix;
in {
  imports = [
    modules/nix/nixops-deploy.nix
    modules/services/fail2ban.nix
    modules/services/openssh.nix
    modules/imports.nix
  ];

  boot.initrd.network = {
    enable = true;
    ssh.enable = true;
    ssh.hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
    ssh.authorizedKeys = my_keys;
  };

  environment.systemPackages = [
    pkgs.speedtest
  ];

  hardware = {
    amd.enable = true;
    enableKvm = true;
  };

  services.vnstat.enable = true;

  users.users = let
    common_keys = import ./ssh_keys.nix;
  in {
    root = {
      openssh.authorizedKeys.keys = my_keys ++ common_keys;
    };
    vali = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = my_keys ++ common_keys;
    };
  };

  zfs = {
    fragmentation = {
      enable = true;
      openFirewall = true;
    };
    enable = true;
  };
}
