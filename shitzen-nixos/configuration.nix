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
      allowedTCPPorts = [ 80 443 4300 ];
    };
    hostName = "shitzen-nixos";
  };

  environment.systemPackages = with pkgs; [
    git
    htop
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
      servers.test = {
        enable = true;
        autoStart = true;
        files = {
          "plugins/Chunky-Bukkit.jar" = pkgs.fetchurl rec {
            pname = "Chunky-Bukkit";
            version = "1.4.28";
            url = "https://cdn.modrinth.com/data/fALzjamp/versions/ytBhnGfO/${pname}-${version}.jar";
            hash = "sha256-G6MwUA+JUDJRkbpwvOC4PnR0k+XuCvcIJnDDXFF3oy4=";
          };
          "plugins/worldedit-bukkit.jar" = pkgs.fetchurl rec {
            pname = "worldedit-bukkit";
            version = "7.3.10-beta-01";
            url = "https://cdn.modrinth.com/data/1u6JkXh5/versions/HIoAq6RI/${pname}-${version}.jar";
            hash = "sha256-uwJgLzUrfflEChTrPibVidYtwyvNJfP8ZmZRLe3SR2A=";
          };
          "plugins/FreedomChat-Paper.jar" = pkgs.fetchurl rec {
            pname = "FreedomChat-Paper";
            version = "1.7.2";
            url = "https://cdn.modrinth.com/data/MubyTbnA/versions/RUlT5EFK/${pname}-${version}.jar";
            hash = "sha256-zD/aUCm5ien8qJv+OCSR7SFpN9TI3GXHXqXFmhqtI3o=";
          };
          "plugins/GeyserExtras.jar" = pkgs.fetchurl rec {
            pname = "GeyserExtras";
            url = "https://cdn.modrinth.com/data/kOfJBurB/versions/jvUySJSF/${pname}.jar";
            hash = "sha256-CQ1v040X8cbGXWyqPg84r56ssXhZRx1WW271gYJ1XZY=";
          };
          "plugins/Vanish.jar" = pkgs.fetchurl rec {
            pname = "Vanish";
            url = "https://cdn.modrinth.com/data/Mv4AIFSE/versions/upXEIsWr/${pname}.jar";
            hash = "sha256-lKjq5VdvRLz0oA3qms+T72Hu0fj288L0QiOUWPD8H0c=";
          };
          "plugins/QualityArmory.jar" = pkgs.fetchurl rec {
            pname = "QualityArmory";
            url = "https://cdn.modrinth.com/data/flkUwsSr/versions/fQtTBG9I/${pname}.jar";
            hash = "sha256-qep6u6HiNhrOigKt86i5sqG6tRnXgcfelJGWZhiyCp0=";
          };
        };
        whitelist = {
          FaintLove = "992e0e99-b817-4f58-96d9-96d4ec8c7d54";
        };
        jvmOpts = "-Xms14G -Xmx14G";
        package = pkgs.paperServers.paper-1_21_4;
        serverProperties = {
          difficulty = "easy";
          enable-rcon = false;
          enforce-whitelist = true;
          gamemode = "survival";
          max-players = 30;
          max-tick-time = 60000;
          motd = "Vali's Minecraft Server";
          server-port = 4300;
          view-distance = 26;
          white-list = true;
        };
      };
    };
  };

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

