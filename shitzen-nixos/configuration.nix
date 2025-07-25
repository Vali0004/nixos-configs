{ config, inputs, lib, pkgs, modulesPath, ... }:

let
  mkForwardTCP = incoming-port: outgoing-port: {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString outgoing-port},bind=10.0.127.3,fork,reuseaddr TCP4:127.0.0.1:${toString incoming-port}";
      KillMode = "process";
      Restart = "always";
    };
  };
  mkForwardUDP = incoming-port: outgoing-port: {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat UDP-LISTEN:${toString outgoing-port},bind=10.0.127.3,fork,reuseaddr UDP:127.0.0.1:${toString incoming-port}";
      KillMode = "process";
      Restart = "always";
    };
  };
in {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    modules/cors-anywhere/service.nix
    modules/convoy/convoy.nix
    modules/agenix.nix
    modules/boot.nix
    modules/docker.nix
    modules/tgt_service.nix
    modules/wireguard.nix
    modules/zfs.nix
    services/arr-services.nix
    services/hydra.nix
    services/jellyfin.nix
    services/mailserver.nix
    services/minecraft.nix
    services/nginx.nix
    services/oauth2.nix
    services/postgresql.nix
    services/proxmox.nix
    services/pterodactyl-panel.nix
    services/redis.nix
    services/rtorrent.nix
    services/samba.nix
    services/tgtd.nix
    services/wings.nix
    services/zipline.nix
  ];

  environment.systemPackages = with pkgs; [
    btop
    docker-compose
    fastfetch
    ffmpeg_6-headless
    git
    hdparm
    iperf
    jdk
    lsscsi
    magic-wormhole
    mysql84
    node2nix
    openssl
    pciutils
    redis
    screen
    sg3_utils
    smartmontools
    tmux
    tshark
    unzip
    wget
    wings
    zip
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/9ffafbc0-8e3a-4f71-80e8-c9f225398340";
      fsType = "ext4";
      options = [ "data=journal" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/9E79-76DF";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
    "/data" = {
      device = "zpool/data";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
  };

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;

  networking = {
    firewall = {
      allowedTCPPorts = [ 25 80 110 111 143 443 465 587 993 995 2049 5001 5201 6379 8080 9000 9080 20048 ];
      allowedUDPPorts = [ 111 2049 6991 20048 ];
    };
    hostId = "0626c0ac";
    hostName = "shitzen-nixos";
    useDHCP = true;
    useNetworkd = true;
    networkmanager.enable = false;
  };

  nix.settings = {
    cores = 4;
    keep-derivations = true;
    max-jobs = 2;
    max-substitution-jobs = 8;
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "diorcheats.vali@gmail.com";
  };

  services = {
    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };
    nfs.server = {
      enable = true;
      exports = ''
        /data 10.0.0.201(rw,sync,no_subtree_check,no_root_squash) 10.0.0.202(rw,sync,no_subtree_check,no_root_squash) 10.0.0.190(rw,sync,no_subtree_check,no_root_squash)
      '';
    };
    toxvpn = {
      auto_add_peers = [
        "12f5850c8664f0ad12047ac2347ef8b1bfb8d26cd37a795c4f7c590cd6b87e7c6b96ca1c9df5" # router
      ];
      localip = "10.0.127.3";
    };
  };

  swapDevices = [{
    device = "/var/lib/swap1";
    size = 8192;
  }];

  systemd.services = {
    forward6990to6991UDP = mkForwardUDP 6990 6991;
  };

  vali.mc_prod = false;
  vali.mc_test = false;

  system.stateVersion = "25.11";
}
