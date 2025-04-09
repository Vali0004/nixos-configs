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
  mkForwardUDP = port: target: {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat UDP-LISTEN:${toString port},reuseaddr,fork UDP:${target}:${toString port}";
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
      device = "/dev/sda";
    };
  };

  networking = {
    defaultGateway = "31.59.128.1";
    firewall = {
      allowedTCPPorts = [ 80 443 4301 5201 8080 ];
      allowedUDPPorts = [ 4301 4302 ];
    };
    hostName = "router";
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "31.59.128.8";
          prefixLength = 24;
        }
      ];
    };
    nameservers = [
      "9.9.9.9"
      "1.1.1.1"
    ];
  };

  environment.systemPackages = with pkgs; [
    ffmpeg_6-headless
    git
    htop
    iperf
    neofetch
    openssl
    wget
  ];

  services = {
    toxvpn = {
      localip = "10.0.127.1";
      auto_add_peers = [ "3e24792c18ab55c59974a356e2195f165e0d967726533818e5ac0361b264ea671d1b3a8ec221" ];
    };
    #openssh.openFirewall = false;
  };

  systemd.services.forward80 = mkForward 80 "10.0.127.3";
  systemd.services.forward443 = mkForward 443 "10.0.127.3";
  systemd.services.forward4301 = mkForward 4301 "10.0.127.3";
  systemd.services.forward8080 = mkForward 8080 "10.0.127.3";
  systemd.services.forwardUDP4301 = mkForwardUDP 4301 "10.0.127.3";
  systemd.services.forwardUDP4302 = mkForwardUDP 4302 "10.0.127.3";

  system.stateVersion = "25.05";
}

