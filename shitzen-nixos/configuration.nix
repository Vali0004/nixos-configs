{ config, inputs, lib, pkgs, modulesPath, ... }:

let
  mkForwardTCP = port: {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},bind=10.0.127.3,fork,reuseaddr TCP4:172.18.0.1:${toString port}";
      KillMode = "process";
      Restart = "always";
    };
  };
  mkForwardUDP = port: {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat UDP-LISTEN:${toString port},bind=10.0.127.3,fork,reuseaddr UDP:172.18.0.1:${toString port}";
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
    modules/zfs.nix
    services/hydra.nix
    services/mailserver.nix
    services/minecraft.nix
    services/nginx.nix
    services/oauth2.nix
    services/postgresql.nix
    services/proxmox.nix
    services/pterodactyl-panel.nix
    services/redis.nix
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
      allowedTCPPorts = [ 25 80 110 111 143 443 465 587 993 995 2049 4100 4101 4301 4302 5001 5201 6379 8080 9000 9080 20048 ];
      allowedUDPPorts = [ 111 2049 4100 4101 4301 4302 20048 ];
    };
    hostId = "0626c0ac";
    hostName = "shitzen-nixos";
    useDHCP = false;
    useNetworkd = true;
    networkmanager.enable = false;
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

  systemd.network = {
    enable = true;
    netdevs."vmbr0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "vmbr0";
      };
      bridgeConfig = {
        ForwardDelaySec = 0;
        HelloTimeSec = 2;
        MaxAgeSec = 20;
        AgeingTimeSec = 300;
        STP = false;
        #MulticastSnooping = false;
      };
    };
    networks."10-enp7s0" = {
      matchConfig.Name = "enp7s0";
      networkConfig = {
        Bridge = "vmbr0";
      };
    };
    networks."10-vmbr0" = {
      matchConfig.Name = "vmbr0";
      networkConfig = {
        Address = [ "10.0.0.244/24" ];
        Gateway = "10.0.0.1";
        DNS = [ "75.75.75.75" "75.75.76.76" ];
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  systemd.services = {
    forward4300 = mkForwardTCP 4300;
    forward4300UDP = mkForwardUDP 4300;
    forward4301 = mkForwardTCP 4301;
    forward4301UDP = mkForwardUDP 4301;
    forward4302 = mkForwardTCP 4302;
    forward4302UDP = mkForwardUDP 4302;
    forward4303 = mkForwardTCP 4303;
    forward4303UDP = mkForwardUDP 4303;
    forward4304 = mkForwardTCP 4304;
    forward4304UDP = mkForwardUDP 4304;
    forward4305 = mkForwardTCP 4305;
    forward4305UDP = mkForwardUDP 4305;
  };

  vali.mc_prod = false;
  vali.mc_test = false;

  system.stateVersion = "25.11";
}
