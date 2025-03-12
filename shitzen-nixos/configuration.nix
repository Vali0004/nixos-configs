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
      ffmpeg_6-headless
      git
      htop
      iperf
      jdk
      neofetch
      node2nix
      nodejs_20
      openssl
      pciutils
      screen
      tmux
      tshark
      unzip
      wget
      zip
    ];
  };
  services = {
    kubo = {
      enable = true;
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
            "/r34/" = {
              proxyPass = "http://127.0.0.1:9090/";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_ssl_server_name on;
                proxy_ssl_name $proxy_host;
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
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
    toxvpn = {
      auto_add_peers = [ "ae395131cb50234bed128ff0ff5ffd495517565b1de6522f41f18a925e575c23978546982368" ];
      localip = "10.0.127.3";
    };
  };

  systemd.services.cors-anywhere = {
    enable = false;
    description = "Proxy to strip CORS from a request";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
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

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

