{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./samba.nix
    ./minecraft.nix
  ];
  
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "minecraft-server"
  ];
  
  # Use the GRUB 2 boot loader.
  boot.loader = {
    grub = {
      memtest86.enable = true;
      copyKernels = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = false;
    };
    efi.canTouchEfiVariables = true;
  };

  networking = {
    firewall =
      if (config.vali.mc_prod || config.vali.mc_test)
      then {
        allowedTCPPorts = [ 80 443 111 2049 20048 4301 5201 8080 ];
        allowedUDPPorts = [ 4301 4302 111 2049 ];
      }
      else {
        allowedTCPPorts = [ 80 443 111 2049 20048 5201 8080 ];
        allowedUDPPorts = [ 111 2049 ];
      };
    hostName = "shitzen-nixos";
  };

  environment = {
    systemPackages = with pkgs; [
      fastfetch
      ffmpeg_6-headless
      git
      htop
      iperf
      jdk
      node2nix
      nodejs_20
      openssl
      pciutils
      screen
      smartmontools
      tmux
      tshark
      unzip
      wget
      zip
      zipline
    ];
  };
  services = {
    kubo = {
      dataDir = "/data/private/ipfs";
      enable = false;
    };
    nfs = {
      server = {
        enable = true;
        exports = ''
          /data 0.0.0.201(rw,sync,no_subtree_check,no_root_squash) 10.0.0.202(rw,sync,no_subtree_check,no_root_squash) 10.0.0.190(rw,sync,no_subtree_check,no_root_squash)
        '';
      };
    };
    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts = {
        "valis.furryporn.ca" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/" = {
              alias = "/data/valisfurryporn/";
              index = "index.html";
            };
          };
        };
        "holy.fuckk.lol" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:3000";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
              '';
            };
          };
        };
        "fuckk.lol" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/private/" = {
              alias = "/data/private/";
              index = "index.htm";
              extraConfig = ''
                autoindex on;
                autoindex_exact_size off;
              '';
            };
            "/r34" = {
              proxyPass = "http://127.0.0.1:8099";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_ssl_server_name on;
                proxy_ssl_name $proxy_host;
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
              '';
            };
            "/" = {
              alias = "/data/web/";
              index = "index.html";
            };
          };
        };
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
    zipline = {
      enable = true;
      settings = {
        CORE_HOSTNAME = "0.0.0.0";
        CORE_PORT = 3000;
        CORE_SECRET = "x9J+)()_(4.7nZ.\8aMj@#7u09u/;=bghpi678ki,k8l";
        DATASOURCE_LOCAL_DIRECTORY = "/data/zipline/uploads";
        DATASOURCE_TYPE = "local";
      };
    };
  };

  systemd.services.cors-anywhere = {
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

  security = {
    acme = {
      acceptTerms = true;
      defaults.email = "diorcheats.vali@gmail.com";
    };
  };

  vali.mc_prod = false;
  vali.mc_test = false;

  system.stateVersion = "25.05";
}

