{
  boot = {
    initrd.availableKernelModules = [
      "ahci" # SATA
      "xhci_pci" # USB
      "usbhid"
      "sdhci_pci" # Storage device host controller PCI
      "sdhci_acpi" # Storage device module
    ];
    kernelModules = [
      "kvm-intel"
    ];
  };

  boot.grub = {
    copyKernels = true;
    efi = {
      enable = true;
      removable = true;
    };
    enable = true;
  };
}