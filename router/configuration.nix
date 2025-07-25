{ config, lib, pkgs, modulesPath, ... }:

let
  mkForward = port: target: {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},reuseaddr,fork TCP4:${target}:${toString port}";
      KillMode = "process";
      Restart = "always";
    };
  };
in {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "ahci" # SATA
        "ata_piix"
        "virtio_blk"
        "virtio_pci"
        "virtio_pci_legacy_dev"
        "virtio_pci_modern_dev"
        "virtio_scsi"
        "uhci_hcd"
        "sd_mod"
        "sr_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    loader.grub = {
      configurationLimit = 3;
      copyKernels = true;
      device = "/dev/vda";
      efiSupport = false;
    };
  };

  environment.systemPackages = with pkgs; [
    fastfetch
    ffmpeg_6-headless
    git
    htop
    iperf
    openssl
    tcpdump
    wget
  ];

  fileSystems = {
    "/" = {
      label = "NIXOS_ROOT";
      fsType = "ext4";
    };
    "/boot" = {
      label = "NIXOS_BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  networking = {
    defaultGateway = "74.208.44.1";
    firewall = {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        465 # SMTPS
        993 # IMAPS
        995 # SPOP3
      ];
    };
    hostName = "router";
    interfaces.ens6 = {
      ipv4.addresses = [{
        address = "74.208.44.130";
        prefixLength = 24;
      }];
    };
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    useDHCP = false;
  };

  nixpkgs = {
    hostPlatform = "x86_64-linux";
  };

  services = {
    toxvpn = {
      localip = "10.0.127.1";
      auto_add_peers = [
        "3e24792c18ab55c59974a356e2195f165e0d967726533818e5ac0361b264ea671d1b3a8ec221" # shitzen
      ];
    };
  };

  swapDevices = [{
    device = "/var/lib/swap1";
    size = 1024;
  }];

  systemd.services = {
    forward25 = mkForward 25 "10.0.127.3";
    forward80 = mkForward 80 "10.0.127.3";
    forward443 = mkForward 443 "10.0.127.3";
    forward465 = mkForward 465 "10.0.127.3";
    forward993 = mkForward 993 "10.0.127.3";
    forward995 = mkForward 995 "10.0.127.3";
  };

  system.stateVersion = "25.05";
}
