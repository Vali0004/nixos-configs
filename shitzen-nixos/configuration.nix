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
    (modulesPath + "/installer/scan/not-detected.nix")
    ./samba.nix
    ./minecraft.nix
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
    nginx = {
      appendHttpConfig = ''
        # Add HSTS header with preloading to HTTPS requests
        map $scheme $hsts_header {
            https   "max-age=31536000; includeSubdomains; preload";
        }
        add_header Strict-Transport-Security $hsts_header;

        # Enable CSP
        #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

        # Minimize information leaked to other domains
        add_header 'Referrer-Policy' 'origin-when-cross-origin';

        # Disable embedding as a frame
        add_header X-Frame-Options DENY;

        # Prevent injection of code in other mime types (XSS Attacks)
        add_header X-Content-Type-Options nosniff;
      '';
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
        "cdn.fuckk.lol" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/rdr3.7z/" = {
              alias = "/data/bruh/";
              index = "index.html";
            };
          };
        };
        "r34.fuckk.lol" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:8099";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_ssl_server_name on;
                proxy_ssl_name $proxy_host;
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Requested-With XMLHttpRequest;
              '';
            };
          };
        };
        "unison.fuckk.lol" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/" = {
              alias = "/data/private/";
              index = "index.htm";
              extraConfig = ''
                return 404;
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
            "/private/nands/" = {
              alias = "/data/private/nands/";
              index = "index.htm";
              extraConfig = ''
                return 404;
              }
              location = "/private/nands/Clever Corona 16mb.zip" {
                alias "/data/private/nands/Clever Corona 16mb.zip";
              }
              location = "/private/nands/White R2D2 Corona 16mb.zip" {
                alias "/data/private/nands/White R2D2 Corona 16mb.zip";
              }
              location = "/private/nands/White Falcon Corona 16mb.zip" {
                alias "/data/private/nands/White Falcon Corona 16mb.zip";
              '';
            };
            "/private/secret/" = {
              alias = "/data/private/secret/";
              index = "index.htm";
              extraConfig = ''
                return 404;
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
    wings = {
      enable = true;
      tokenFile = "/data/private/secret/wingsFile";
      config = {
        uuid = "85da3dd7-7d31-4f60-9dc0-b06212f248cc";
        token_id = "fmtcooaiB2dEnGPO";
        remote = "https://panel.r33.live";
        api = {
          host = "0.0.0.0";
          port = 9000;
          ssl = {
            enabled = true;
            cert = "/var/lib/acme/unison.fuckk.lol/fullchain.pem";
            key = "/var/lib/acme/unison.fuckk.lol/key.pem";
          };
        };
        system = {
          root_directory = "/data/pterodactyl/data";
          log_directory = "/data/pterodactyl/logs";
          data = "/data/pterodactyl/data/volumes";
          archive_directory = "/data/pterodactyl/data/archives";
          backup_directory = "/data/pterodactyl/data/backups";
        };
      };
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

  swapDevices = [
    {
      device = "/var/lib/swap1";
      size = 8192;
    }
  ];

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
    zipline = {
      serviceConfig = {
        ReadWritePaths = [ "/data/zipline/uploads" ];
      };
    };
    forward4301 = mkForward "10.0.127.3" 4301 "172.18.0.1";
    forwardUDP4301 = mkForwardUDP "10.0.127.3" 4301 "172.18.0.1";
    forward4302 = mkForward "10.0.127.3" 4302 "172.18.0.1";
    forwardUDP4302 = mkForwardUDP "10.0.127.3" 4302 "172.18.0.1";
  };

  users = {
    groups.pterodactyl = {};
    users = {
      pterodactyl = {
        extraGroups = [ "docker" "nginx" ];
        group = "pterodactyl";
        isSystemUser = true;
      };
    };
  };

  vali.mc_prod = false;
  vali.mc_test = false;

  virtualisation = {
    docker.enable = true;
  };

  system.stateVersion = "25.05";
}

