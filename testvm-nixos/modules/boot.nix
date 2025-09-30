{ config, pkgs, ... }:

{
  boot = {
    consoleLogLevel = 0;
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "ahci" # PS/2
        "virtio_blk" # VirtualIO Block Devices
        "virtio_pci" # VirtualIO PCI Devices
        "xhci_pci" # USB
        "sr_mod"
      ];
      kernelModules = [ ];
      systemd.enable = true;
    };
    kernelModules = [ "kvm-amd" ];
    kernelParams = [
      "boot.shell_on_fail"
      "memtest=1"
      "rd.systemd.show_status=auto"
      "splash"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        memtest86.enable = true;
        copyKernels = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = false;
        zfsSupport = true;
      };
      timeout = 2;
    };
    tmp = {
      useTmpfs = false;
      cleanOnBoot = true;
    };
  };
}