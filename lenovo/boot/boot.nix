{ config, lib, pkgs, ... }:

{
  imports = [
    ./kernel.nix
    ./loader.nix
    ./rescue.nix
    ./zfs.nix
  ];

  boot.consoleLogLevel = 0;

  boot.extraModprobeConfig = "options vfio-pci ids=1002:7340,1002:ab38";
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
