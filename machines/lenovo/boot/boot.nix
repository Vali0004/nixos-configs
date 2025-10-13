{ ... }:

{
  boot.initrd.availableKernelModules = [
    "nvme" # NVME
    "usb_storage" # USB
    "xhci_pci" # USB
    "sd_mod" # SD
    # SD Card
    "sdhci_pci"
  ];

  boot.grub = {
    copyKernels = true;
    efi.enable = true;
    enable = true;
    enableMemtest = true;
    enableRescue = true;
  };
}
