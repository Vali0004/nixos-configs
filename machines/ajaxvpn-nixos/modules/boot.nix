{
  boot = {
    initrd.availableKernelModules = [
      # ATA PIIX
      "ata_piix"
      # USB HCI
      "uhci_hcd"
      # VirtIO PCI
      "virtio_pci"
      # VirtIO SCSI
      "virtio_scsi"
      # Storage device module
      "sd_mod"
      # Storage rom module
      "sr_mod"
    ];
    kernelModules = [
      "kvm-intel"
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.tcp_syncookies" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  boot.grub = {
    enable = true;
    configurationLimit = 10;
    copyKernels = true;
    device = "/dev/sda";
  };
}