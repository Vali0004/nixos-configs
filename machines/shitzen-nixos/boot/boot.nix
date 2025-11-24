{ config, pkgs, ... }:

{
  boot = {
    initrd.availableKernelModules = [
      # SATA
      "ahci"
      # Net Console
      "netconsole"
      # SAS
      "mpt3sas"
      "raid_class"
      "scsi_transport_sas"
      # Storage device module
      "sd_mod"
      # USB
      "usb_storage"
      "usbhid"
      "xhci_pci"
    ];
    kernel.sysctl = {
      "net.ipv4.ip_forward" = true;
    };
    kernelModules = [
      "netconsole"
    ];
    extraModprobeConfig = ''
      options netconsole netconsole=6665@10.0.0.6/eth0,6666@10.0.0.189/10:ff:e0:35:08:fb
    '';
    kernelParams = [
      "netconsole=6665@10.0.0.6/eth0,6666@10.0.0.189/10:ff:e0:35:08:fb"
      "memtest=1"
    ];
  };

  boot.consoleLogLevel = 8;

  boot.grub = {
    copyKernels = true;
    efi.enable = true;
    enable = true;
    enableMemtest = true;
    enableRescue = true;
  };
}