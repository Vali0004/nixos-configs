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
      memtest86.enable = true;
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
    ffmpeg_6-headless
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
        "fuckk.lol" = {
          enableACME = true;
          enableSSL = true;
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
      enable = false;
      eula = true;
      # As much as I want to have this go on the HDD, it's simply too slow.
      dataDir = "/var/lib/minecraft";
      servers = {
        test = {
          enable = false;
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
            Killer4563782 = "f159afef-984e-4343-bd7b-d94cfff96c63";
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
            max-threads = 8;
            max-tick-time = 60000;
            motd = "Vali's Test Minecraft Server";
            query-port = 4300;
            server-name = "InertiaCraftTest";
            server-port = 4300;
            simulation-distance = 24;
            texturepack-required = true;
            tick-distance = 12;
            view-distance = 24;
            white-list = true;
          };
        };
        prod = {
          enable = false;
          autoStart = true;
          files = {
            "mods/fabric-api.jar" = pkgs.fetchurl rec {
              pname = "fabric-api";
              version = "0.114.0%2B1.21.4";
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/5tj7y3PJ/${pname}-${version}.jar";
              hash = "sha256-TATNEpMOzG19eCI5NDhdYonSpkRLzH3q9T49o3kgHC0=";
            };
            "mods/cloth-config.jar" = pkgs.fetchurl rec {
              pname = "cloth-config";
              version = "17.0.144-fabric";
              url = "https://cdn.modrinth.com/data/9s6osm5g/versions/TJ6o2sr4/${pname}-${version}.jar";
              hash = "sha256-H9oMSonU8HXlGz61VwpJEocGVtJS2AbqMJHSu8Bngeo=";
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
            "mods/noisium.jar" = pkgs.fetchurl rec {
              pname = "noisium";
              version = "fabric-2.5.0%2Bmc1.21.4";
              url = "https://cdn.modrinth.com/data/KuNKN7d2/versions/9NHdQfkN/${pname}-${version}.jar";
              hash = "sha256-JmSbfF3IDaC1BifR8WaKFCpam6nHlBWQzVryDR6Wvto=";
            };
            "mods/c2me.jar" = pkgs.fetchurl rec {
              pname = "c2me";
              version = "fabric-mc1.21.4-0.3.1.0";
              url = "https://cdn.modrinth.com/data/VSNURh3q/versions/fBvLHC54/${pname}-${version}.jar";
              hash = "sha256-7gnbVMLOvbWQS+FNrHBSYn4wsI/mwjhkB8nn2qmKeJQ=";
            };
            "mods/balm.jar" = pkgs.fetchurl rec {
              pname = "balm";
              version = "fabric-1.21.4-21.4.5";
              url = "https://cdn.modrinth.com/data/MBAkmtvl/versions/9pTQ0wCu/${pname}-${version}.jar";
              hash = "sha256-dj/zhNd1WIMs5pj3LL6myKx9TlhHkOS7W5IDvk02KXg=";
            };
            "mods/netherportalfix.jar" = pkgs.fetchurl rec {
              pname = "netherportalfix";
              version = "fabric-1.21.4-21.4.1";
              url = "https://cdn.modrinth.com/data/nPZr02ET/versions/QFwLWcVf/${pname}-${version}.jar";
              hash = "sha256-Mzs9yz38b3+wrOFzQYUm8ufGF26Pm3VFULPrnKU/Nk8=";
            };
            "mods/Almanac.jar" = pkgs.fetchurl rec {
              pname = "Almanac";
              version = "1.21.3-fabric-1.4.4";
              url = "https://cdn.modrinth.com/data/Gi02250Z/versions/inGMPti6/${pname}-${version}.jar";
              hash = "sha256-uUzohqWvbxvlb9Y0vUMY03BQg/W0k0gi/BxYa7zkw48=";
            };
            "mods/letmedespawn.jar" = pkgs.fetchurl rec {
              pname = "letmedespawn";
              version = "1.21.x-fabric-1.4.4";
              url = "https://cdn.modrinth.com/data/vE2FN5qn/versions/e0AXgTFp/${pname}-${version}.jar";
              hash = "sha256-TTXnoq5R6EX7zBUscbMtonOBYO3zSvDtDg/XqWGkZMg=";
            };
            "mods/MRU.jar" = pkgs.fetchurl rec {
              pname = "MRU";
              version = "1.0.7%2B1.21.4%2Bfabric";
              url = "https://cdn.modrinth.com/data/SNVQ2c0g/versions/YMG8XHkz/${pname}-${version}.jar";
              hash = "sha256-sXe42FK7g5AKzBVYarDy/0T9zC0czVzFRoF2Ww7t+DU=";
            };
            "mods/SnowUnderTrees.jar" = pkgs.fetchurl rec {
              pname = "SnowUnderTrees";
              version = "2.6.0%2B1.21.4";
              url = "https://cdn.modrinth.com/data/XVnUIUAQ/versions/cuMgw6kW/${pname}-${version}.jar";
              hash = "sha256-FbBpPHrewYDzkc6SY0pJt57PWy8INgc/9YmjVnNv94Q=";
            };
            # Multi-version interop
            "mods/ViaFabric.jar" = pkgs.fetchurl rec {
              pname = "ViaFabric";
              version = "0.4.17%2B91-main";
              url = "https://cdn.modrinth.com/data/YlKdE5VK/versions/Niu0KrUK/${pname}-${version}.jar";
              hash = "sha256-gJQYHj9O2IZ7iKkZcLbuDiEmGIogHipFmJR/8b9lpPM=";
            };
            "mods/ViaBackwards.jar" = pkgs.fetchurl rec {
              pname = "ViaBackwards";
              version = "5.2.1";
              url = "https://cdn.modrinth.com/data/NpvuJQoq/versions/bprnc7WS/${pname}-${version}.jar";
              hash = "sha256-RMDwGh1aZzOM+O9Zz3+7zkyCdv/yLx/bNM7tb0ZjMN8=";
            };
            "mods/ViaRewind.jar" = pkgs.fetchurl rec {
              pname = "ViaRewind";
              version = "4.0.5";
              url = "https://cdn.modrinth.com/data/TbHIxhx5/versions/qf3oSwsb/${pname}-${version}.jar";
              hash = "sha256-ZMdA0yEqZm/9Vs3nq4fCai7GbLgKahBGsY3kP+M9s3U=";
            };
            "mods/ViaVersion.jar" = pkgs.fetchurl rec {
              pname = "ViaVersion";
              version = "5.2.1";
              url = "https://cdn.modrinth.com/data/P1OZGk5p/versions/p5sXOzZW/${pname}-${version}.jar";
              hash = "sha256-yaWqtqxikpaiwdeyfANzu6fp3suSF8ePmJXs9dN4H8g=";
            };
            # Admin mods
            "mods/collective.jar" = pkgs.fetchurl rec {
              pname = "collective";
              version = "1.21.4-7.89";
              url = "https://cdn.modrinth.com/data/e0M1UDsY/versions/F3ciVO4i/${pname}-${version}.jar";
              hash = "sha256-iPn6vhB0rDa5EoJhNYIbpDNj5ii6XdCdSsxifSaVk2U=";
            };
            #"mods/beautifiedchatserver.jar" = pkgs.fetchurl rec {
            #  pname = "beautifiedchatserver";
            #  version = "1.21.4-2.6";
            #  url = "https://cdn.modrinth.com/data/C00Y5Ci9/versions/904kQvXX/${pname}-${version}.jar";
            #  hash = "sha256-OCZEbQFbeFnFji7D1GovFYJ57S1SlpRjt6UjBPLE+Ak=";
            #};
            "mods/player-roles.jar" = pkgs.fetchurl rec {
              pname = "player-roles";
              version = "1.6.13";
              url = "https://cdn.modrinth.com/data/Rt1mrUHm/versions/Y5EAJzwR/${pname}-${version}.jar";
              hash = "sha256-rqFqiCgfRn2LOKqVpo9KQVnn/VnD//sBbXoa7sctiZw=";
            };
            "config/roles.json" = builtins.toFile "json" (builtins.toJSON {
              admin = {
                level = 100;
                overrides = {
                  name_decoration = {
                    style = ["red" "bold"];
                    suffix = {
                      text = "*";
                    };
                  };
                  permission_level = 4;
                  command_feedback = true;
                  commands = {
                    ".*" = "allow";
                  };
                };
              };
              spectator = {
                level = 10;
                overrides = {
                  commands = {
                    "gamemode (spectator|adventure)" = "allow";
                  };
                };
              };
              mute = {
                level = 1;
                overrides = {
                  mute = true;
                };
              };
              everyone = {
                overrides = {
                  commands = {
                    help = "allow";
                    ".*" = "deny";
                  };
                };
              };
            });
          };
          whitelist = {
            FaintLove = "992e0e99-b817-4f58-96d9-96d4ec8c7d54";
            SOLOZ01 = "a02466ff-a71b-4540-8838-1b850cd4f659";
            Killer4563782 = "f159afef-984e-4343-bd7b-d94cfff96c63";
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
            max-threads = 16;
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
  #systemd.services.minecraft-server-prod.serviceConfig.TimeoutStopSec = lib.mkForce "10s";

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

