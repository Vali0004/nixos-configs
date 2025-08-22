{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking = {
    networkmanager.unmanaged = [ "interface-name:wg0" "interface-name:wg1" ];
    firewall = {
      allowPing = true;
      allowedUDPPorts = [ 51820 51821 ];
      checkReversePath = false;
      interfaces.wg0 = {
        allowedTCPPortRanges = [{
          from = 0;
          to = 65535;
        }];
      };
      interfaces.wg1 = {
        allowedTCPPortRanges = [{
          from = 0;
          to = 65535;
        }];
      };
    };
    nat = {
      enable = true;
      externalInterface = "enp7s0";
      internalInterfaces = [ "wg0" ];
      forwardPorts = [
        { proto = "udp"; sourcePort = 51820; destination = "10.0.0.244"; }
      ];
    };
    interfaces.wg0.useDHCP = false;
    interfaces.wg1.useDHCP = false;
  };

  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      fwMark = "0xca6c";
      ips = [ "10.127.0.3/32" ];
      listenPort = 51820;
      postSetup = ''
        # Setup route
        ${pkgs.iproute2}/bin/ip route add 74.208.44.130 via 10.0.0.1 dev enp7s0 table 100
        # Route table 100 for wg0
        ${pkgs.iproute2}/bin/ip rule add fwmark 0xca6c table 100
        ${pkgs.iproute2}/bin/ip route add default dev wg0 table 100

        # Save/restore connmark for wg0
        ${pkgs.iptables}/bin/iptables -t mangle -A PREROUTING \
          -i wg0 -p udp \
          -m comment --comment "wg0 restore mark" \
          -j CONNMARK --restore-mark --nfmask 0xffffffff --ctmask 0xffffffff
        ${pkgs.iptables}/bin/iptables -t mangle -A POSTROUTING \
          -o enp7s0 \
          -m mark --mark 0xca6c \
          -m comment --comment "wg0 save mark" \
          -j CONNMARK --save-mark --nfmask 0xffffffff --ctmask 0xffffffff

        # Restrict access to wg0 subnet
        ${pkgs.iptables}/bin/iptables -t raw -A PREROUTING -d 10.127.0.0/24 \
          ! -i wg0 -m addrtype ! --src-type LOCAL \
          -m comment --comment "block non-wg0 access to 10.127.0.0/24" \
          -j DROP
      '';
      postShutdown = ''
        # Cleanup routes
        ${pkgs.iproute2}/bin/ip route del 74.208.44.130 via 10.0.0.1 dev enp7s0 table 100 || true
        ${pkgs.iproute2}/bin/ip rule del fwmark 0xca6c table 100 || true
        ${pkgs.iproute2}/bin/ip route flush table 100 || true

        ${pkgs.iptables}/bin/iptables -t mangle -D PREROUTING \
          -i wg0 -p udp \
          -m comment --comment "wg0 restore mark" \
          -j CONNMARK --restore-mark --nfmask 0xffffffff --ctmask 0xffffffff || true
        ${pkgs.iptables}/bin/iptables -t mangle -D POSTROUTING \
          -o enp7s0 \
          -m mark --mark 0xca6c \
          -m comment --comment "wg0 save mark" \
          -j CONNMARK --save-mark --nfmask 0xffffffff --ctmask 0xffffffff || true

        ${pkgs.iptables}/bin/iptables -t raw -D PREROUTING -d 10.127.0.0/24 \
          ! -i wg0 -m addrtype ! --src-type LOCAL \
          -m comment --comment "block non-wg0 access to 10.127.0.0/24" \
          -j DROP || true
      '';
      peers = [{
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "74.208.44.130:51820";
        persistentKeepalive = 25;
        publicKey = "EjPutSj3y/DuPfz4F0W3PYz09Rk+XObW2Wh4W5cDrwA=";
      }];
      privateKeyFile = config.age.secrets.wireguard.path;
    };
    interfaces.wg1 = {
      fwMark = "0xca7f";
      ips = [ "10.100.0.1/24" ];
      listenPort = 51821;
      postSetup = ''
        # Route table 101 for wg1
        ${pkgs.iproute2}/bin/ip route add 142.167.46.223 via 10.0.0.1 dev enp7s0 table 101
        ${pkgs.iproute2}/bin/ip rule add fwmark 0xca7f table 101
        ${pkgs.iproute2}/bin/ip route add default dev wg0 table 101

        # Save/restore connmark for wg1
        ${pkgs.iptables}/bin/iptables -t mangle -A PREROUTING \
          -i wg1 -p udp \
          -m comment --comment "wg1 restore mark" \
          -j CONNMARK --restore-mark || true
        ${pkgs.iptables}/bin/iptables -t mangle -A POSTROUTING \
          -o enp7s0 -m mark --mark 0xca7f \
          -m comment --comment "wg1 save mark" \
          -j CONNMARK --save-mark || true

        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg1 -o enp7s0 -j ACCEPT
      '';
      postShutdown = ''
        ${pkgs.iproute2}/bin/ip route del 142.167.46.223 via 10.0.0.1 dev enp7s0 table 101 || true
        ${pkgs.iproute2}/bin/ip rule del fwmark 0xca7f table 101 || true
        ${pkgs.iproute2}/bin/ip route flush table 101 || true

        ${pkgs.iptables}/bin/iptables -t mangle -D PREROUTING \
          -i wg1 -p udp \
          -m comment --comment "wg1 restore mark" \
          -j CONNMARK --restore-mark || true
        ${pkgs.iptables}/bin/iptables -t mangle -D POSTROUTING \
          -o enp7s0 -m mark --mark 0xca7f \
          -m comment --comment "wg1 save mark" \
          -j CONNMARK --save-mark || true

        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg1 -o enp7s0 -j ACCEPT || true
      '';
      peers = [
        {
          allowedIPs = [ "10.100.0.2/32" ];
          publicKey = "JlHHaH807y8/qcHlgm0RBzrd1/NLkgzvQJCiqTlK6mU=";
        }
        {
          allowedIPs = [ "10.100.0.3/32" ];
          publicKey = "M+2/DTWFGyoG3xRymv/UasKTXJCsxJUddURwnh1MfAI=";
        }
        {
          allowedIPs = [ "10.100.0.4/32" ];
          publicKey = "GqdlynLTZTbYkYKP5cBMmRrAWLdHVSYEBPrZf6A+SXQ=";
        }
      ];
      privateKeyFile = config.age.secrets.wireguard-down.path;
    };
  };
}