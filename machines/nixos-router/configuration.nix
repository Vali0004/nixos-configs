{ pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    modules/boot.nix

    services/prometheus.nix
    services/xdp.nix
  ];

  environment.systemPackages = with pkgs; [
    conntrack-tools
    fastfetch
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
    hostId = "bade5fb2";
    hostName = "nixos-router";
    interfaces = {
      enp4s0.useDHCP = true;
    };
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
      "2001:4860:4860::8888"
      "2606:4700:4700::1111"
    ];
    useDHCP = false;
    # We actually have 2 PHYs, so this is needed :/
    usePredictableInterfaceNames = true;
  };

  swapDevices = [{
    device = "/dev/disk/by-label/NIXOS_SWAP";
  }];

  system.stateVersion = "25.11";

  users.users = {
    vali.extraGroups = [ "video" "render" ];
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWxSLK5fZYYfrGT/B0trFhaToJYtoUp+GsAy9a/e2Mo"
    ];
  };

  zfs = {
    autoSnapshot.enable = true;
    fragmentation = {
      enable = true;
      openFirewall = true;
    };
  };
}