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
    firewall = {
      allowedTCPPorts = [ 80 443 4300 4301 ];
      allowedUDPPorts = [ 4301 4302 ];
    };
    hostName = "shitzen-nixos";
  };

  environment.systemPackages = with pkgs; [
    ffmpeg_6-headless
    git
    htop
    neofetch
    openssl
    pciutils
    screen
    tmux
    tshark
    unzip
    wget
    zip
  ];

  services = {
    nginx = {
      enable = true;
      virtualHosts = {
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
  #systemd.services.minecraft-server-prod.serviceConfig.TimeoutStopSec = lib.mkForce "10s";

  security = {
    acme = {
      acceptTerms = true;
      defaults.email = "diorcheats.vali@gmail.com";
    };
  };

  vali.mc_prod = true;
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

