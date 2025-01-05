{ config, lib, pkgs, ... }:

let
  mkForward = port: target: {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},reuseaddr,fork TCP4:${target}:${toString port}";
      KillMode = "process";
      Restart = "always";
    };
  };
in {
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader = {
    grub = {
      device = "/dev/vda";
    };
  };

  networking = {
    defaultGateway = "31.59.128.1";
    extraHosts = ''
    127.0.0.1 ext.earthtools.ca
    '';
    firewall = {
      allowedUDPPorts = [  ];
      allowedTCPPorts = [ 80 443 4300 4301 ];
    };
    hostName = "router";
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "31.59.128.34";
          prefixLength = 24;
        }
      ];
    };
    nameservers = [
      "9.9.9.9"
      "8.8.4.4"
    ];
  };

  environment.systemPackages = with pkgs; [
    ffmpeg_6-headless
    git
    htop
    openssl
    wget
  ];

  services = {
    toxvpn = {
      localip = "10.0.127.1";
      auto_add_peers = [ "3e24792c18ab55c59974a356e2195f165e0d967726533818e5ac0361b264ea671d1b3a8ec221" ];
    };
  };

  systemd.services.forward80 = mkForward 80 "10.0.127.3";
  systemd.services.forward443 = mkForward 443 "10.0.127.3";
  systemd.services.forward4300 = mkForward 4300 "10.0.127.3";
  systemd.services.forward4301 = mkForward 4301 "10.0.127.3";

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

