{ config, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [
    "bridge" "br_netfilter" # networkd
    "ahci" # SATA
    "xhci_pci" # USB
    "usb_storage"
    "usbhid"
    "sd_mod"
    "mpt3sas" "raid_class" "scsi_transport_sas" # SAS
  ];

  boot.kernelParams = [
    "memtest=1"
    "netconsole=6665@10.0.0.244/eth0,6666@10.0.0.201/10:ff:e0:35:08:fb"
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
  };

  boot.grub = {
    copyKernels = true;
    efi.enable = true;
    enable = true;
    enableMemtest = true;
  };
}