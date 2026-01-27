{
  boot = {
    blacklistedKernelModules = [
      "amdgpu"
    ];
    kernelModules = [
      "radeon"
    ];
    initrd.availableKernelModules = [
      "ahci" # SATA
      "ohci_pci" # USB
      "ehci_pci" # USB
      "usbhid"
      "sd_mod"
      "scsi_mod"
    ];
  };

  # forcei686 doesn't work with ZFS
  nixpkgs.overlays = [(self: super: {
    inherit (super.pkgsi686Linux) grub2_efi;
  })];

  boot.grub = {
    copyKernels = true;
    efi = {
      enable = true;
      removable = true;
    };
    enable = true;
  };
}