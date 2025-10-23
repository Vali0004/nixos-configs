{ config, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [
    # SATA
    "ahci"
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

  boot.consoleLogLevel = 8;

  boot.extraModprobeConfig = ''
    options netconsole netconsole=6665@10.0.0.244/eth0,6666@10.0.0.201/10:ff:e0:35:08:fb
  '';

  boot.kernelParams = [
    "memtest=1"
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
  };

  boot.grub = {
    copyKernels = true;
    efi.enable = true;
    enable = true;
    enableMemtest = true;
  };
}