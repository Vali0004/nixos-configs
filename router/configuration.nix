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
  mkForwardUDP = port: target: {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat UDP-LISTEN:${toString port},reuseaddr,fork UDP:${target}:${toString port}";
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
      allowedTCPPorts = [ 25 80 110 143 443 465 587 993 995 2022 4100 4101 4301 5001 5201 6379 8080 8096 9000 50000 ];
      allowedUDPPorts = [ 4100 4101 4301 4302 4303 4304 4305 ];
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
    forward110 = mkForward 110 "10.0.127.3";
    forward143 = mkForward 143 "10.0.127.3";
    forward443 = mkForward 443 "10.0.127.3";
    forward465 = mkForward 465 "10.0.127.3";
    forward587 = mkForward 587 "10.0.127.3";
    forward993 = mkForward 993 "10.0.127.3";
    forward995 = mkForward 995 "10.0.127.3";
    forward2022 = mkForward 2022 "10.0.127.3";
    forward4100 = mkForward 4100 "10.0.127.3";
    forward4101 = mkForward 4101 "10.0.127.3";
    forward4301 = mkForward 4301 "10.0.127.3";
    forward4302 = mkForward 4302 "10.0.127.3";
    forward4303 = mkForward 4303 "10.0.127.3";
    forward4304 = mkForward 4304 "10.0.127.3";
    forward4305 = mkForward 4305 "10.0.127.3";
    forward5001 = mkForward 5001 "10.0.127.3";
    forward5201 = mkForward 5201 "10.0.127.3";
    forward6379 = mkForward 6379 "10.0.127.3";
    forward8080 = mkForward 8080 "10.0.127.3";
    forward8096 = mkForward 8096 "10.0.127.3";
    forward9000 = mkForward 9000 "10.0.127.3";
    forward50000 = mkForward 50000 "10.0.127.3";
    forwardUDP4100 = mkForwardUDP 4100 "10.0.127.3";
    forwardUDP4101 = mkForwardUDP 4101 "10.0.127.3";
    forwardUDP4301 = mkForwardUDP 4301 "10.0.127.3";
    forwardUDP4302 = mkForwardUDP 4302 "10.0.127.3";
    forwardUDP4303 = mkForwardUDP 4303 "10.0.127.3";
    forwardUDP4304 = mkForwardUDP 4304 "10.0.127.3";
    forwardUDP4305 = mkForwardUDP 4305 "10.0.127.3";
  };

  system.stateVersion = "25.05";
}
