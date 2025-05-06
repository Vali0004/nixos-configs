{ config, inputs, lib, pkgs, modulesPath, ... }:

let
  mkForward = ip: port: target: {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},bind=${ip},fork,reuseaddr TCP4:${target}:${toString port}";
      KillMode = "process";
      Restart = "always";
    };
  };
  mkForwardUDP = ip: port: target: {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat UDP-LISTEN:${toString port},bind=${ip},fork,reuseaddr UDP:${target}:${toString port}";
      KillMode = "process";
      Restart = "always";
    };
  };
in {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    services/minecraft.nix
    services/nginx.nix
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
      (php.buildEnv {
        extensions = {
          enabled,
          all,
        }: enabled ++ (with all; [
            redis
        ]);
        extraConfig = ''
          memory_limit = 2G
        '';
      })
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
      allowedTCPPorts = [ 80 443 111 4301 5201 8080 9000 ];
      allowedUDPPorts = [ 4301 4302 111 ];
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
    forward4301 = mkForward "10.0.127.3" 4301 "172.18.0.1";
    forwardUDP4301 = mkForwardUDP "10.0.127.3" 4301 "172.18.0.1";
    forward4302 = mkForward "10.0.127.3" 4302 "172.18.0.1";
    forwardUDP4302 = mkForwardUDP "10.0.127.3" 4302 "172.18.0.1";
  };

  vali.mc_prod = false;
  vali.mc_test = false;

  system.stateVersion = "25.05";
}

