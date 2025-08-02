{ config, pkgs, ... }:

{
  boot = {
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "bridge" "br_netfilter" # networkd
        "ahci" # SATA
        "xhci_pci" # USB
        "usb_storage"
        "usbhid"
        "sd_mod"
        "mpt3sas" "raid_class" "scsi_transport_sas" # SAS
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    kernelParams = [
      "netconsole=6665@10.0.0.244/enp7s0,6666@10.0.0.0.201/10:ff:e0:35:08:fb"
    ];
    kernel.sysctl."net.ipv4.ip_forward" = true;
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        memtest86.enable = true;
        copyKernels = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = false;
      };
    };
  };
}