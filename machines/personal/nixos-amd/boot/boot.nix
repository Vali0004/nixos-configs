{ config
, ... }:

{
  imports = [
    ./kernel.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "powerpc64-linux" "armv7l-linux" "aarch64-linux" "riscv64-linux" ];
    extraModprobeConfig = ''
      options rtw89_core disable_ps_mode=y
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    '';
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback.out
    ];
    initrd.availableKernelModules = [
      "ahci" # SATA
      "bridge" "br_netfilter" # networkd
      "nvme" # NVME
      "usbhid" "usb_storage" # USB
      "xhci_pci" # USB
      "sd_mod"
    ];
    kernelModules = [
      # Binary Format
      "binfmt_misc"
      # USB Monitor
      "usbmon"
      # Razer Keyboard
      "razerkbd"
      # SMBus
      "i2c-dev"
      "i2c-smbus"
      "i2c-piix4"
      "sp5100_tco"
      "at24"
      "ee1004"
      # Virtual Camera
      "v4l2loopback"
      # Virtual Microphone, built-in
      "snd-aloop"
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
      ## 384 MiB: 0xab8000000 - 0xacfffffff
      #"memmap=384M!0xab8000000"
      ## 192 MiB: 0xb00000000 - 0xb0bffffff
      #"memmap=192M!0xb00000000"
      ## 32 MiB: 0xcaa000000 - 0xcabffffff
      #"memmap=32M!0xca8000000"
    ];
  };

  boot.grub = {
    copyKernels = true;
    efi = {
      enable = true;
      enableSecureBoot = true;
    };
    enable = true;
    enableMemtest = true;
    enableRescue = false;
    enableProber = true;
  };
}