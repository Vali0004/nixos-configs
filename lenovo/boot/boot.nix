{ config, lib, pkgs, ... }:

{
  imports = [
    ./../../modules/boot/rescue/module.nix
    ./../../modules/boot/grub-efi.nix
    ./kernel.nix
    ./zfs.nix
  ];

  boot.consoleLogLevel = 0;

  boot.extraModulePackages = [ ];

  boot.initrd = {
    availableKernelModules = [
      "nvme" # NVME
      "usb_storage" # USB
      "xhci_pci" # USB
      "sd_mod" # SD
      # SD Card
      "sdhci_pci"
    ];
    kernelModules = [ ];
    systemd.enable = true;
    # Silence Stage 1
    verbose = true;
  };

  boot.tmp.useTmpfs = false;
}
