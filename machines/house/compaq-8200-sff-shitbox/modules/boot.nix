{
  boot = {
    initrd.availableKernelModules = [
      "ahci" # SATA
      "ehci_pci" # USB
      "sd_mod" # Storage device module
      "sr_mod" # Storage ROM device module
    ];
    kernelParams = [
      "iomem=relaxed"
    ];
  };

  boot.grub = {
    copyKernels = true;
    efi = {
      enable = true;
      removable = true;
    };
    enable = true;
    enableMemtest = true;
  };
}