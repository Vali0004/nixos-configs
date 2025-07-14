{ config, pkgs, ... }:

{
  boot = {
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
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