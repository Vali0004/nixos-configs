{ config
, lib
, pkgs
, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # E6530: i7-3540M, the HD 4000 drives the panel (keep Optimus on in the BIOS)
  boot = {
    grub = {
      enable = true;
      efi.enable = true;
      # the E6530 firmware only finds EFI/BOOT/BOOTX64.EFI on the internal disk
      efi.removable = true;
      device = "nodev";
    };

    # vfio-pci claims the NVS 5200M, its HDMI audio and the Wi-Fi card for PD test VMs
    extraModprobeConfig = ''
      options vfio-pci ids=10de:0dfc,10de:0bea,8086:422b
      softdep nouveau pre: vfio-pci
      softdep snd_hda_intel pre: vfio-pci
      softdep iwlwifi pre: vfio-pci
    '';
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      "vfio-pci.ids=10de:0dfc,10de:0bea,8086:422b"
    ];
  };

  environment.systemPackages = [
    pkgs.qemu
    (pkgs.writeShellScriptBin "pd-igpu" (builtins.readFile ./pd-igpu.sh))
  ];

  hardware = {
    intel.enable = true;
    intel-gpu.enable = true;
    virtualisation.enable = true;
  };

  networking = {
    hostName = "e6530";
    networkmanager.enable = true;
  };

  services.openssh.enable = true;

  zfs.enable = false;

  zramSwap.enable = true;

  system.stateVersion = "26.11";
}
