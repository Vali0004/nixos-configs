{ config, inputs, lib, pkgs, ... }:

{ 
  imports = [
    ./hardware-configuration.nix
  ];
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "minecraft-server"
  ];
  
  # Use the GRUB 2 boot loader.
  boot.loader = {
    grub = {
      copyKernels = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = false;
    };
    efi.canTouchEfiVariables = true;
  };

  networking = {
    firewall = {
      allowedUDPPorts = [  ];
      allowedTCPPorts = [ 80 443 4300 4301 ];
    };
    hostName = "shitzen-nixos";
  };

  environment.systemPackages = with pkgs; [
    git
    htop
    ncurses
    ncurses5
    neofetch
    openssl
    tmux
    unzip
    wget
    zip
  ];

  services = {
    toxvpn = {
      localip = "10.0.127.3";
      auto_add_peers = [ "ae395131cb50234bed128ff0ff5ffd495517565b1de6522f41f18a925e575c23978546982368" ];
    };
    nginx = {
      enable = true;
      virtualHosts = {
        "10.0.127.3" = {
          enableSSL = false;
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
    minecraft-servers = {
      eula = true;
      enable = true;
      # As much as I want to have this go on the HDD, it's simply too slow.
      dataDir = "/var/lib/minecraft";
      servers = {
        test = {
          enable = true;
          autoStart = true;
          files = {
            "mods/fabric-api.jar" = pkgs.fetchurl rec {
              pname = "fabric-api";
              version = "0.114.0%2B1.21.4";
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/5tj7y3PJ/${pname}-${version}.jar";
              hash = "sha256-TATNEpMOzG19eCI5NDhdYonSpkRLzH3q9T49o3kgHC0=";
            };
            "mods/ferritecore.jar" = pkgs.fetchurl rec {
              pname = "ferritecore";
              version = "7.1.1-fabric";
              url = "https://cdn.modrinth.com/data/uXXizFIs/versions/IPM0JlHd/${pname}-${version}.jar";
              hash = "sha256-DdXpIDVSAk445zoPW0aoLrZvAxiyMonGhCsmhmMnSnk=";
            };
            "mods/lithium.jar" = pkgs.fetchurl rec {
              pname = "lithium";
              version = "fabric-0.14.3%2Bmc1.21.4";
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/t1FlWYl9/${pname}-${version}.jar";
              hash = "sha256-LJFVhw/3MnsPnYTHVZbM3xJtne1lV5twuYeqZSMZEn4=";
            };
            "mods/modernfix.jar" = pkgs.fetchurl rec {
              pname = "modernfix";
              version = "fabric-5.20.1%2Bmc1.21.4";
              url = "https://cdn.modrinth.com/data/nmDcB62a/versions/gx7PIV8n/${pname}-${version}.jar";
              hash = "sha256-yDjUaCH3wW/e5ccG4tpeO4JkMJScj8EbDSvQTlLVu+s=";
            };
            "mods/memoryleakfix.jar" = pkgs.fetchurl rec {
              pname = "memoryleakfix";
              version = "fabric-1.17%2B-1.1.5";
              url = "https://cdn.modrinth.com/data/NRjRiSSD/versions/5xvCCRjJ/${pname}-${version}.jar";
              hash = "sha256-uKwz1yYuAZcQ3SXkVBFmFrye0fcU7ZEFlLKKTB2lrd4=";
            };
            "mods/krypton.jar" = pkgs.fetchurl rec {
              pname = "krypton";
              version = "0.2.8";
              url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/Acz3ttTp/${pname}-${version}.jar";
              hash = "sha256-lPGVgZsk5dpk7/3J2hXN2Eg2zHXo/w/QmLq2vC9J4/4=";
            };
            "mods/Debugify.jar" = pkgs.fetchurl rec {
              pname = "Debugify";
              version = "1.21.4%2B1.0";
              url = "https://cdn.modrinth.com/data/QwxR6Gcd/versions/TxwUizo2/${pname}-${version}.jar";
              hash = "sha256-9f1/iLjcor5vkWoHjiRggP8zhTc3fY80d6hJZeb9OeU=";
            };
          };
          whitelist = {
            FaintLove = "992e0e99-b817-4f58-96d9-96d4ec8c7d54";
            SOLOZ01 = "a02466ff-a71b-4540-8838-1b850cd4f659";
          };
          jvmOpts = "-Xms4G -Xmx4G";
          package = pkgs.fabricServers.fabric-1_21_4;
          serverProperties = {
            admin-slot = true;
            allow-cheats = true;
            compression-algorithm = "zlib";
            compression-threshold = 2;
            difficulty = "hard";
            enable-command-block = true;
            enable-rcon = false;
            enforce-whitelist = true;
            entity-broadcast-range-percentage = 50;
            force-gamemode = false;
            gamemode = "survival";
            hardcore = false;
            max-players = 3;
            max-threads = 4;
            max-tick-time = 60000;
            motd = "Vali's Test Minecraft Server";
            query-port = 4300;
            server-name = "InertiaCraftTest";
            server-port = 4300;
            simulation-distance = 12;
            texturepack-required = true;
            tick-distance = 6;
            view-distance = 12;
            white-list = true;
          };
        };
        prod = {
          enable = true;
          autoStart = true;
          files = {
            "mods/fabric-api.jar" = pkgs.fetchurl rec {
              pname = "fabric-api";
              version = "0.114.0%2B1.21.4";
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/5tj7y3PJ/${pname}-${version}.jar";
              hash = "sha256-TATNEpMOzG19eCI5NDhdYonSpkRLzH3q9T49o3kgHC0=";
            };
            #"mods/cloth-config.jar" = pkgs.fetchurl rec {
            #  pname = "cloth-config";
            #  version = "17.0.144-fabric";
            #  url = "https://cdn.modrinth.com/data/9s6osm5g/versions/TJ6o2sr4/${pname}-${version}.jar";
            #  hash = "sha256-H9oMSonU8HXlGz61VwpJEocGVtJS2AbqMJHSu8Bngeo=";
            #};
            "mods/ferritecore.jar" = pkgs.fetchurl rec {
              pname = "ferritecore";
              version = "7.1.1-fabric";
              url = "https://cdn.modrinth.com/data/uXXizFIs/versions/IPM0JlHd/${pname}-${version}.jar";
              hash = "sha256-DdXpIDVSAk445zoPW0aoLrZvAxiyMonGhCsmhmMnSnk=";
            };
            "mods/lithium.jar" = pkgs.fetchurl rec {
              pname = "lithium";
              version = "fabric-0.14.3%2Bmc1.21.4";
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/t1FlWYl9/${pname}-${version}.jar";
              hash = "sha256-LJFVhw/3MnsPnYTHVZbM3xJtne1lV5twuYeqZSMZEn4=";
            };
            "mods/modernfix.jar" = pkgs.fetchurl rec {
              pname = "modernfix";
              version = "fabric-5.20.1%2Bmc1.21.4";
              url = "https://cdn.modrinth.com/data/nmDcB62a/versions/gx7PIV8n/${pname}-${version}.jar";
              hash = "sha256-yDjUaCH3wW/e5ccG4tpeO4JkMJScj8EbDSvQTlLVu+s=";
            };
            "mods/memoryleakfix.jar" = pkgs.fetchurl rec {
              pname = "memoryleakfix";
              version = "fabric-1.17%2B-1.1.5";
              url = "https://cdn.modrinth.com/data/NRjRiSSD/versions/5xvCCRjJ/${pname}-${version}.jar";
              hash = "sha256-uKwz1yYuAZcQ3SXkVBFmFrye0fcU7ZEFlLKKTB2lrd4=";
            };
            "mods/krypton.jar" = pkgs.fetchurl rec {
              pname = "krypton";
              version = "0.2.8";
              url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/Acz3ttTp/${pname}-${version}.jar";
              hash = "sha256-lPGVgZsk5dpk7/3J2hXN2Eg2zHXo/w/QmLq2vC9J4/4=";
            };
            "mods/Debugify.jar" = pkgs.fetchurl rec {
              pname = "Debugify";
              version = "1.21.4%2B1.0";
              url = "https://cdn.modrinth.com/data/QwxR6Gcd/versions/TxwUizo2/${pname}-${version}.jar";
              hash = "sha256-9f1/iLjcor5vkWoHjiRggP8zhTc3fY80d6hJZeb9OeU=";
            };
            "mods/NoChatReports.jar" = pkgs.fetchurl rec {
              pname = "NoChatReports";
              version = "FABRIC-1.21.4-v2.11.0";
              url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/9xt05630/${pname}-${version}.jar";
              hash = "sha256-1jMJbw5wL/PwsNSEHs4MHJpjyvPVhbhiP59dnXRQJwI=";
            };
          };
          whitelist = {
            FaintLove = "992e0e99-b817-4f58-96d9-96d4ec8c7d54";
            SOLOZ01 = "a02466ff-a71b-4540-8838-1b850cd4f659";
          };
          jvmOpts = "-Xms10G -Xmx10G";
          package = pkgs.fabricServers.fabric-1_21_4;
          serverProperties = {
            admin-slot = true;
            allow-cheats = true;
            compression-algorithm = "zlib";
            compression-threshold = 2;
            difficulty = "hard";
            enable-command-block = true;
            enable-rcon = false;
            enforce-whitelist = true;
            entity-broadcast-range-percentage = 110;
            force-gamemode = false;
            gamemode = "survival";
            hardcore = false;
            max-players = 30;
            max-threads = 10;
            max-tick-time = 60000;
            motd = "Vali's Minecraft Server";
            query-port = 4301;
            server-name = "InertiaCraft";
            server-port = 4301;
            simulation-distance = 26;
            texturepack-required = true;
            tick-distance = 16;
            view-distance = 28;
            white-list = true;
          };
        };
      };
    };
  };
  #systemd.services.minecraft-server-prod.serviceConfig.StartLimitBurst = 500;
  systemd.services.minecraft-server-prod.serviceConfig.TimeoutStopSec = lib.mkForce "10s";
  #systemd.services.minecraft-server-test.serviceConfig.StartLimitBurst = 500;
  #systemd.services.minecraft-server-test.serviceConfig.TimeoutStopSec = lib.mkForce "10s";

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

