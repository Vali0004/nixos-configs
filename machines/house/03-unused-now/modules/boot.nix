{
  boot = {
    initrd.availableKernelModules = [
      "ahci" # SATA
      "xhci_pci" # USB
      "sdhci_pci" # Storage device host controller PCI
      "sd_mod" # Storage device module
    ];
  };

  boot.grub = {
    copyKernels = true;
    efi.enable = true;
    enable = true;
    enableMemtest = true;
  };
}