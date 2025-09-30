{ config, lib, modulesPath, pkgs, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    modules/agenix.nix
    modules/boot.nix
    modules/wireguard.nix
    modules/zfs.nix
  ];

  console.keyMap = "us";

  environment.systemPackages = with pkgs; [
    # Better TOP
    btop
    # cURL
    curl
    # Domain Name System Utilities
    dnsutils
    # Modern Neofetch
    fastfetch
    # Internet performance tool
    iperf
    # SSL Client
    openssl
    # Stack Trace
    strace
    # WebGet
    wget
  ];

  environment.persistence."/persistent" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/etc"
      "/var/log/journal"
      "/var/lib/nixos"
      "/var/lib/vnstat"
      "/var/lib/systemd/coredump"
    ];
    users = {
      root = {
        home = "/root";
        directories = [
          { directory = ".ssh"; mode = "0700"; }
        ];
        files = [
          ".bash_history"
        ];
      };
      vali = {
        directories = [
          { directory = ".ssh"; mode = "0700"; }
        ];
        files = [
          ".bash_history"
        ];
      };
    };
  };

  fileSystems = {
    # Mount the Root Partition
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=25%" "mode=755" ];
    };
    "/persistent" = {
      device = "zpool/persistent";
      neededForBoot = true;
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
    # Mount the EFI Partition
    "/boot" = {
      fsType = "vfat";
      label = "NIXOS_BOOT";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  networking = {
    defaultGateway = "192.168.122.1";
    defaultGateway6 = {
      address = "fe80::";
      interface = "eth0";
    };
    hostName = "testvm-nixos";
    hostId = "6a3cd947";
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "192.168.122.242";
        prefixLength = 24;
      }];
      ipv6.addresses = [
        {
          address = "fe80::5054:ff:fe0b:eb1b";
          prefixLength = 64;
        }
      ];
    };
    nameservers = [
      "75.75.75.75"
      "75.75.76.76"
    ];
    networkmanager.dns = "none";
    resolvconf.useLocalResolver = false;
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  programs = {
    command-not-found.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
  };

  system.stateVersion = "25.11";

  swapDevices = [ ];
}
