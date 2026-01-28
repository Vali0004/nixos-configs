{ config
, pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"

    modules/boot.nix
    services/windowManager.nix
  ];

  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty
    # Binary Tools
    bintools
    # Better TOP
    btop
    # cURL
    curl
    # Useful for DNS debugging
    dig
    # Display Mode Info Decode
    dmidecode
    # Ethernet tool
    ethtool
    # Modern neofetch
    fastfetch
    # Version Tracking
    git
    # Jellyfin
    kodi
    # Internet Utilities
    inetutils
    # NCurses Disk usage
    ncdu
    # Open SSL
    openssl
    # PCI Utilies
    pciutils
    # Python - useful for some scripts
    python3
    # Screen
    screen
    # USB Utilies
    usbutils
    # Web Get
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

  hardware = {
    amd.enable = true;
    # We have graphics support, might as well enable it; although, we don't need 32-bit support
    graphics.enable = true;
  };

  programs = {
    command-not-found.enable = true;
    dconf.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
    google-chrome.enable = true;
    zsh.enable = true;
  };

  networking = {
    hostId = "bade5fb2";
    hostName = "nixos-jaguar";
    interfaces = {
      eth0.useDHCP = true;
    };
    usePredictableInterfaceNames = false;
  };

  services = {
    udisks2.enable = true;
    #getty.autologinUser = "vali";
    xserver = {
      enable = true;
      # Disable XTerm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
  };

  swapDevices = [{
    device = "/dev/disk/by-label/NIXOS_SWAP";
  }];

  users.users = {
    vali.extraGroups = [ "video" "render" ];
  };

  # modules/zfs/module.nix
  # modules/zfs/fragmentation.nix
  zfs.autoSnapshot.enable = true;
}