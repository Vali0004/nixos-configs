{
  boot = {
    blacklistedKernelModules = [
      # Pre-GCN APU, it has a stroke elsewise
      "amdgpu"
    ];
    initrd.availableKernelModules = [
      "ahci" # SATA
      "ohci_pci" # USB
      "ehci_pci" # Ethernet PCI
      "sd_mod" # Storage device module
    ];
    kernelModules = [
      "binfmt_misc"
      "usbmon"
    ];
    kernelParams = [
      "iomem=relaxed"
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.tcp_syncookies" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  # Force my module off
  boot.grub = {
    enable = false;
  };

  # Fucking Dell.
  nixpkgs.overlays = [(self: super: { inherit (super.pkgsi686Linux) grub2_efi; })];
  boot.loader = {
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      configurationLimit = 1;
      copyKernels = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      memtest86.enable = true;
    };
    timeout = 10;
  };
}