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
      /*commonHttpConfig =
      let
        realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
        fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
        cfipv4 = fileToList (pkgs.fetchurl {
          url = "https://www.cloudflare.com/ips-v4";
          sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
        });
        cfipv6 = fileToList (pkgs.fetchurl {
          url = "https://www.cloudflare.com/ips-v6";
          sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
        });
      in
        ''
          ${realIpsFromList cfipv4}
          ${realIpsFromList cfipv6}
          real_ip_header CF-Connecting-IP;
        '';*/
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

