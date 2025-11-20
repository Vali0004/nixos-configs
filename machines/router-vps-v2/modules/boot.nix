{
  boot.initrd.availableKernelModules = [
    "ahci" # SATA
    # Virtual IO
    "virtio_net"
    "virtio_pci"
    "virtio_scsi"
    "uhci_hcd"
    "ehci_pci"
    "sd_mod"
    "sr_mod"
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv4.tcp_syncookies" = true;
    "net.netfilter.nf_conntrack_max" = 25594;
  };

  boot.grub = {
    enable = true;
    efi.enable = true;
    copyKernels = true;
  };
}