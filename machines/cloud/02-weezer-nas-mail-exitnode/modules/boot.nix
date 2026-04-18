{
  boot = {
    initrd.availableKernelModules = [
      "uhci_hcd" # USB 1.0
      "ehci_pci" # USB 2.0
      "ahci" # SATA
      "virtio_pci" # VirtualIO PCI
      "virtio_scsi" # VirtualIO SCSI
      "sd_mod" # Storage device module
      "sr_mod" # Storage ROM device module
    ];
    kernel.sysctl = {
      "net.ipv4.ip_forward" = true;
      "net.ipv4.tcp_syncookies" = true;
      "net.ipv6.conf.all.forwarding" = true;
      "net.netfilter.nf_conntrack_max" = 25594;
      "kernel.hung_task_panic" = 1;
      "kernel.panic" = 30;
    };
  };

  boot.grub = {
    enable = true;
    configurationLimit = 3;
    copyKernels = true;
    efi = {
      enable = true;
      removable = true;
    };
  };
}