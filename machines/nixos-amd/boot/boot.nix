{
  imports = [
    ./kernel.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "powerpc64-linux" "armv7l-linux" ];
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
    kernelParams = [
      #
      # As much as I don't like covering this large area,
      # there's too much bad ram, and I feel safer just saying "screw it, yank the whole area"
      #
      # 0xabb4e5d48-0xabb4e9d48 has bad bits
      # 0xabb4f1d48-0xabb4f5d48 has bad bits
      # 0xabb4fdd48-0xb013de500 has bad bits
      # 0xb013de580-0xb013e2500 has bad bits
      # 0xb013e25a8-0xb013e6510 has bad bits
      # 0xb013e6580-0xb013ea500 has bad bits
      # 0xb013ea5a0-0xb013ee590 has bad bits
      # 0xb013ee5a8-0xb013f6500 has bad bits
      # 0xb013f6500-0xb013fa5b8 has bad bits
      # 0xb013fe500-0xb013fe580 has bad bits
      "memtest=1"
      "memmap=1M!0xabb400000"
      "memmap=8M!0xb01380000"
    ];
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