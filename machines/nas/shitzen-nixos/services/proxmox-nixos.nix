{ config,
... }:

{
  networking = {
    bridges.vmbr0.interfaces = [ "enp4s0" ];
    interfaces.vmbr0.useDHCP = true;
  };

  services.proxmox-ve = {
    enable = true;
    bridges = [ "vmbr0" ];
    ipAddress = "10.0.0.4";
    openFirewall = true;
  };
}