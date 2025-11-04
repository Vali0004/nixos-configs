{
  imports = [
    ./kernel.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "powerpc64-linux" ];
    extraModprobeConfig = "options vfio-pci ids=1002:7340,1002:ab38";
    initrd.availableKernelModules = [
      "ahci" # SATA
      "bridge" "br_netfilter" # networkd
      "nvme" # NVME
      "usbhid" "usb_storage" # USB
      "xhci_pci" # USB
      "sd_mod"
    ];
    kernelModules = [
      "binfmt_misc"
      "usbmon"
      "razerkbd"
    ];
  };

  boot.grub = {
    copyKernels = true;
    efi.enable = true;
    enable = true;
    enableMemtest = true;
    enableRescue = true;
  };
}