{
  imports = [
    ./kernel.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "powerpc64-linux" "arm-linux-gnueabihf" ];
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
    kernel.sysctl = {
      "net.ipv4.ip_forward" = true;
      "net.ipv4.tcp_syncookies" = true;
      "net.ipv6.conf.all.forwarding" = true;
    };
  };

  boot.grub = {
    copyKernels = true;
    efi.enable = true;
    enable = true;
    enableMemtest = true;
    enableRescue = true;
    enableProber = true;
  };
}