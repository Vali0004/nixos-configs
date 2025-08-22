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
      internalInterfaces = [ "wg0" "wg1" ];
      forwardPorts = [
        { proto = "udp"; sourcePort = 51820; destination = "10.0.0.244"; }
        { proto = "udp"; sourcePort = 51821; destination = "10.0.0.244"; }
        { proto = "udp"; sourcePort = 51822; destination = "10.0.0.244"; }
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
        ${pkgs.iproute2}/bin/ip route add 74.208.44.130 via 10.0.0.1 dev enp7s0
        # Restore mark for wg0
        ${pkgs.iptables}/bin/iptables -t mangle -A PREROUTING \
          -p udp \
          -m comment --comment "wg0 restore mark" \
          -j CONNMARK --restore-mark --nfmask 0xffffffff --ctmask 0xffffffff

        # Save mark for wg0
        ${pkgs.iptables}/bin/iptables -t mangle -A POSTROUTING \
          -p udp \
          -m mark --mark 0xca6c \
          -m comment --comment "wg0 save mark" \
          -j CONNMARK --save-mark --nfmask 0xffffffff --ctmask 0xffffffff

        # Block non-wg0 access to 10.127.0.0
        ${pkgs.iptables}/bin/iptables -t raw -A PREROUTING \
          -d 10.127.0.0/24 \
          ! -i wg0 \
          -m addrtype ! --src-type LOCAL \
          -m comment --comment "block non-wg0 access to 10.127.0.0/24" \
          -j DROP
      '';
      postShutdown = ''
        # Cleanup route
        ${pkgs.iproute2}/bin/ip route del 74.208.44.130 via 10.0.0.1 dev enp7s0 || true
        # Restore mark for wg0
        ${pkgs.iptables}/bin/iptables -t mangle -D PREROUTING \
          -p udp \
          -m comment --comment "wg0 restore mark" \
          -j CONNMARK --restore-mark --nfmask 0xffffffff --ctmask 0xffffffff || true

        # Save mark for wg0
        ${pkgs.iptables}/bin/iptables -t mangle -D POSTROUTING \
          -p udp \
          -m mark --mark 0xca6c \
          -m comment --comment "wg0 save mark" \
          -j CONNMARK --save-mark --nfmask 0xffffffff --ctmask 0xffffffff || true

        # Block non-wg0 access to 10.127.0.0
        ${pkgs.iptables}/bin/iptables -t raw -D PREROUTING \
          -d 10.127.0.0/24 \
          ! -i wg0 \
          -m addrtype ! --src-type LOCAL \
          -m comment --comment "block non-wg0/wg1 access to 10.127.0.0/24" \
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
        ${pkgs.iptables}/bin/iptables -A FORWARD -i enp7s0 -o wg0 -p udp --dport 51821 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -o enp7s0 -p udp --sport 51820 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -o enp7s0 -p udp --sport 51821 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -o enp7s0 -p udp --sport 51822 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -i enp7s0 -o wg1 -p udp --dport 51821 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg1 -o enp7s0 -p udp --sport 51820 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg1 -o enp7s0 -p udp --sport 51821 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg1 -o enp7s0 -p udp --sport 51822 -j ACCEPT
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i enp7s0 -o wg0 -p udp --dport 51821 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -o enp7s0 -p udp --sport 51820 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -o enp7s0 -p udp --sport 51821 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -o enp7s0g -p udp --sport 51822 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D FORWARD -i enp7s0 -o wg1 -p udp --dport 51821 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg1 -o enp7s0 -p udp --sport 51820 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg1 -o enp7s0 -p udp --sport 51821 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg1 -o enp7s0 -p udp --sport 51822 -j ACCEPT || true
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
      ];
      privateKeyFile = config.age.secrets.wireguard-down.path;
    };
  };
}