{ config
, lib
, pkgs
, ... }:

let
  cfg = config.router;
  iptables = pkgs.iptables;
  toxIf = "tox_master0";
  wanIp = "76.112.236.206";
in {
  networking.nat = {
    enable = true;
    externalInterface = cfg.wanInterface;
    internalInterfaces = [ cfg.bridgeInterface ];
    forwardPorts = [
      {
        # ssh
        destination = "${cfg.lanSubnet}.4:22";
        proto = "tcp";
        sourcePort = 2222;
        loopbackIPs = [ wanIp ];
      }
      {
        # iperf2
        destination = "${cfg.lanSubnet}.4:5201";
        proto = "tcp";
        sourcePort = 5201;
        loopbackIPs = [ wanIp ];
      }
      {
        # WireGuard
        destination = "${cfg.lanSubnet}.4:51820";
        proto = "udp";
        sourcePort = 51820;
        loopbackIPs = [ wanIp ];
      }
      {
        # WireGuard Internal
        destination = "${cfg.lanSubnet}.4:51821";
        proto = "udp";
        sourcePort = 51821;
        loopbackIPs = [ wanIp ];
      }
      {
        # Wings
        destination = "${cfg.lanSubnet}.4:8900";
        proto = "tcp";
        sourcePort = 8900;
        loopbackIPs = [ wanIp ];
      }
      {
        # Wings port 1
        destination = "${cfg.lanSubnet}.4:8901";
        proto = "tcp";
        sourcePort = 8901;
        loopbackIPs = [ wanIp ];
      }
      {
        # Wings port 1
        destination = "${cfg.lanSubnet}.4:8901";
        proto = "udp";
        sourcePort = 8901;
        loopbackIPs = [ wanIp ];
      }
      {
        # Wings port 2
        destination = "${cfg.lanSubnet}.4:8902";
        proto = "tcp";
        sourcePort = 8902;
        loopbackIPs = [ wanIp ];
      }
      {
        # Wings port 2
        destination = "${cfg.lanSubnet}.4:8902";
        proto = "udp";
        sourcePort = 8902;
        loopbackIPs = [ wanIp ];
      }
      {
        # Wings port 3
        destination = "${cfg.lanSubnet}.4:8903";
        proto = "tcp";
        sourcePort = 8903;
        loopbackIPs = [ wanIp ];
      }
      {
        # Wings port 3
        destination = "${cfg.lanSubnet}.4:8903";
        proto = "udp";
        sourcePort = 8903;
        loopbackIPs = [ wanIp ];
      }
      {
        # Wings port 4
        destination = "${cfg.lanSubnet}.4:8904";
        proto = "udp";
        sourcePort = 8904;
        loopbackIPs = [ wanIp ];
      }
      {
        # Wings port 4
        destination = "${cfg.lanSubnet}.4:8904";
        proto = "tcp";
        sourcePort = 8904;
        loopbackIPs = [ wanIp ];
      }
    ];
  };

  networking.nftables.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ cfg.bridgeInterface ];
    extraForwardRules = ''
      iifname "${cfg.bridgeInterface}" oifname "${cfg.wanInterface}" accept
      iifname "${cfg.wanInterface}" oifname "${cfg.bridgeInterface}" ct state established,related accept
    '';
  };
}