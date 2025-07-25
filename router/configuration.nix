{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./agenix.nix
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
    wget
    wireguard-tools
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
      allowedTCPPorts = [ 25 80 110 143 443 465 587 993 995 2022 5001 5201 6379 8080 8096 9000 50000 51820 ];
      allowedUDPPorts = [ 6991 ];
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
    nat = {
      enable = true;
      externalInterface = "ens6";
      internalInterfaces = [ "wg0" ];
    };
    wireguard = {
      enable = true;
      interfaces.wg0 = {
        ips = [ "10.0.127.1/24" ];
        listenPort = 51820;
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.127.0/24 -o ens6 -j MASQUERADE
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.127.0/24 -o ens6 -j MASQUERADE
        '';
        privateKeyFile = config.age.secrets.wireguard-server.path;
        peers = [
          {
            publicKey = "";
            allowedIPs = [ "10.0.127.3/32" ];
          }
        ];
      };
    };
    useDHCP = false;
  };

  nixpkgs = {
    hostPlatform = "x86_64-linux";
  };

  swapDevices = [{
    device = "/var/lib/swap1";
    size = 1024;
  }];

  system.stateVersion = "25.05";
}
