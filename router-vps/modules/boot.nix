{ config, lib, pkgs, ... }:

{
  boot = {
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "ahci" # SATA
        "ata_piix"
        "virtio_blk"
        "virtio_pci"
        "virtio_pci_legacy_dev"
        "virtio_pci_modern_dev"
        "virtio_scsi"
        "uhci_hcd"
        "sd_mod"
        "sr_mod"
      ];
      kernelModules = [ ];
    };
    kernel.sysctl."net.ipv4.ip_forward" = true;
    kernel.sysctl."net.ipv4.tcp_syncookies" = true;
    kernel.sysctl."net.netfilter.nf_conntrack_max" = 25594;
    kernelModules = [ "kvm-amd" ];
    loader.grub = {
      configurationLimit = 3;
      copyKernels = true;
      device = "/dev/vda";
      efiSupport = false;
    };
  };
}