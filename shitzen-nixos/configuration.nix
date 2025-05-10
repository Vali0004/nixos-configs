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
    services/mailserver.nix
    services/minecraft.nix
    services/nginx.nix
    services/php.nix
    services/pterodactyl-panel.nix
    services/redis.nix
    services/samba.nix
    services/wings.nix
    services/zipline.nix
  ];

  # Use the GRUB 2 boot loader.
  boot = {
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        memtest86.enable = true;
        copyKernels = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = false;
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      docker-compose
      fastfetch
      ffmpeg_6-headless
      git
      htop
      iperf
      jdk
      magic-wormhole
      node2nix
      nodejs_20
      nodePackages.pnpm
      nodePackages.yarn
      mysql84
      openssl
      pciutils
      redis
      screen
      smartmontools
      tmux
      tshark
      unzip
      wget
      wings
      zip
      zipline
      zstd  
    ];
  };

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
      fsType = "ext4";
      label = "MAIN";
    };
  };

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;

  networking = {
    firewall = {
      allowedTCPPorts = [ 25 80 110 111 143 443 465 587 993 995 4100 4101 4301 4302 5201 6379 8080 9000 ];
      allowedUDPPorts = [ 111 4100 4101 4301 4302 ];
    };
    hostName = "shitzen-nixos";
    useDHCP = true;
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  security = {
    acme = {
      acceptTerms = true;
      defaults = {
        email = "diorcheats.vali@gmail.com";
      };
    };
  };

  services = {
    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };
    nfs = {
      server = {
        enable = true;
        exports = ''
          /data 0.0.0.201(rw,sync,no_subtree_check,no_root_squash) 10.0.0.202(rw,sync,no_subtree_check,no_root_squash) 10.0.0.190(rw,sync,no_subtree_check,no_root_squash)
        '';
      };
    };
    postgresql = {
      enable = true;
      settings.port = 5432;
    };
    toxvpn = {
      auto_add_peers = [
        "a4ae9a2114f5310bef4381c463c09b9491c7f0cf0e962bc8083620e2555fd221020e75e411b4"
      ];
      localip = "10.0.127.3";
    };
  };

  swapDevices = [{
    device = "/var/lib/swap1";
    size = 8192;
  }];

  systemd.services = {
    cors-anywhere = {
      enable = true;
      description = "Proxy to strip CORS from a request";
      unitConfig = {
        Type = "simple";
      };
      serviceConfig = {
        Environment = "PORT=8099";
        ExecStart = "/nix/store/j7dx1n6m5axf9r2bvly580x2ixx546wq-nodejs-20.18.1/bin/node /root/cors-anywhere/result/lib/node_modules/cors-anywhere/server.js";
      };
      wantedBy = [ "multi-user.target" ];
    };
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

  system.stateVersion = "25.05";
}

