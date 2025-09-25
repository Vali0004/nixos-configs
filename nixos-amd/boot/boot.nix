{ config, lib, pkgs, ... }:

{
  imports = [
    ./../../modules/boot/rescue/module.nix
    ./../../modules/boot/grub-efi.nix
    ./kernel.nix
  ];

  boot.consoleLogLevel = 0;

  boot.extraModprobeConfig = "options vfio-pci ids=1002:7340,1002:ab38";
  boot.extraModulePackages = [ ];

  boot.initrd = {
    availableKernelModules = [
      "ahci" # SATA
      "bridge" "br_netfilter" # networkd
      "nvme" # NVME
      "usbhid" "usb_storage" # USB
      "xhci_pci" # USB
      "sd_mod"
    ];
    kernelModules = [ ];
    systemd.enable = true;
    # Silence Stage 1
    verbose = false;
  };

  boot.tmp.useTmpfs = false;
}
