{ config, pkgs, lib, ... }:

{
  services.proxmox-ve = {
    bridges = [ "vmbr0" ];
    enable = true;
    ipAddress = "10.0.0.244";
  };

  systemd.tmpfiles.rules = [
    # Make proxmox-pve happy
    "d /run/pve 0755 root root -"
  ];
}