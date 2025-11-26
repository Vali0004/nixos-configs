{ pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    modules/boot.nix

    services/prometheus.nix
  ];

  environment.systemPackages = with pkgs; [
    bintools
    binwalk
    conntrack-tools
    dmidecode
    fastfetch
    flashrom
    gdb
    git
    htop
    inetutils
    iperf
    minica
    ncdu
    ndisc6
    net-tools
    openssl
    pciutils
    screen
    tcpdump
    wget
  ];

  fileSystems = {
    "/" = {
      device = "zpool/root";
      fsType = "zfs";
    };
    "/home" = {
      device = "zpool/home";
      neededForBoot = true;
      fsType = "zfs";
    };
    "/nix" = {
      device = "zpool/nix";
      neededForBoot = true;
      fsType = "zfs";
    };
    "/boot" = {
      label = "NIXOS_BOOT";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  networking = {
    defaultGateway = "45.139.50.1";
    defaultGateway6 = {
      address = "2a0b:64c0:2::1";
      interface = "eth0";
    };
    hostId = "bade5fb2";
    hostName = "ajaxvpn-nixos";
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "45.139.50.22";
        prefixLength = 24;
      }];
      ipv6.addresses = [
        {
          address = "2a0b:64c0:2::11e";
          prefixLength = 47;
        }
        {
          address = "fe80::be24:11ff:fea5:6b4";
          prefixLength = 64;
        }
      ];
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "2001:4860:4860::8888"
      "2606:4700:4700::1111"
    ];
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  swapDevices = [{
    device = "/dev/disk/by-label/NIXOS_SWAP";
  }];

  system.stateVersion = "25.11";

  zfs = {
    autoSnapshot.enable = true;
    fragmentation = {
      enable = true;
      openFirewall = true;
    };
  };
}