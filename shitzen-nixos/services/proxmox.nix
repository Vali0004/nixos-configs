{ config, pkgs, lib, ... }:

{
  services.proxmox-ve = {
    bridges = [ "vmbr0" ];
    enable = true;
    ipAddress = "10.0.0.159";
  };

  systemd.tmpfiles.rules = [
    # Make proxmox-pve happy
    "d /run/pve 0755 root root -"
  ];

  services.nginx.virtualHosts."proxmox.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://127.0.0.1:8006";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_ssl_verify off;
      '';
    };
  };

  systemd.network = {
    enable = true;
    netdevs."vmbr0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "vmbr0";
      };
      bridgeConfig = {
        ForwardDelaySec = 0;
        HelloTimeSec = 2;
        MaxAgeSec = 20;
        AgeingTimeSec = 300;
        STP = false;
        #MulticastSnooping = false;
      };
    };
    networks."10-enp7s0" = {
      matchConfig.Name = "enp7s0";
      networkConfig = {
        Bridge = "vmbr0";
      };
    };
    networks."10-enp7s0-bridge" = {
      matchConfig.Name = "vmbr0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  virtualisation.vswitch.enable = true;
}