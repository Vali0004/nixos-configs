{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking = {
    networkmanager.unmanaged = [ "interface-name:wg0" "interface-name:wg1" ];
    firewall = {
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
      externalInterface = "wg0";
      internalInterfaces = [ "wg1" ];
    };
    interfaces.wg0.useDHCP = false;
    interfaces.wg1.useDHCP = false;
  };

  #networking.wg-quick = {
  #  interfaces = {
  #    wg0 = {
  #      address = [ "10.127.0.3/32" ];
  #      privateKeyFile = config.age.secrets.wireguard.path;
  #      peers = [{
  #        allowedIPs = [ "0.0.0.0/0" ];
  #        endpoint = "74.208.44.130:51820";
  #        persistentKeepalive = 25;
  #        publicKey = "EjPutSj3y/DuPfz4F0W3PYz09Rk+XObW2Wh4W5cDrwA=";
  #      }];
  #    };
  #  };
  #};

  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      fwMark = "0xca6c";
      ips = [ "10.127.0.3/32" ];
      listenPort = 51820;
      postSetup = ''
        # Setup route
        ${pkgs.iproute2}/bin/ip route add 74.208.44.130 via 10.0.0.1 dev enp7s0
        # Restore mark for inbound UDP (wg0)
        ${pkgs.iptables}/bin/iptables -t mangle -A PREROUTING \
          -p udp \
          -m comment --comment "wg0 restore mark" \
          -j CONNMARK --restore-mark --nfmask 0xffffffff --ctmask 0xffffffff
        # Save mark for outbound UDP (wg0)
        ${pkgs.iptables}/bin/iptables -t mangle -A POSTROUTING \
          -p udp \
          -m mark --mark 0xca6c \
          -m comment --comment "wg0 save mark" \
          -j CONNMARK --save-mark --nfmask 0xffffffff --ctmask 0xffffffff
        # Allow traffic to 10.127.0.3 from wg0 or wg1, drop everything else
        ${pkgs.iptables}/bin/iptables -t raw -A PREROUTING \
          -d 10.127.0.3/32 \
          -i wg1 \
          -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t raw -A PREROUTING \
          -d 10.127.0.3/32 \
          ! -i wg0 \
          -m addrtype ! --src-type LOCAL \
          -m comment --comment "block non-wg0/wg1 access to 10.127.0.3" \
          -j DROP
      '';
      postShutdown = ''
        ${pkgs.iproute2}/bin/ip route del 74.208.44.130 via 10.0.0.1 dev enp7s0 || true
        ${pkgs.iptables}/bin/iptables -t mangle -D PREROUTING \
          -p udp \
          -m comment --comment "wg0 restore mark" \
          -j CONNMARK --restore-mark --nfmask 0xffffffff --ctmask 0xffffffff || true
        ${pkgs.iptables}/bin/iptables -t mangle -D POSTROUTING \
          -p udp \
          -m mark --mark 0xca6c \
          -m comment --comment "wg0 save mark" \
          -j CONNMARK --save-mark --nfmask 0xffffffff --ctmask 0xffffffff || true
        ${pkgs.iptables}/bin/iptables -t raw -D PREROUTING \
          -d 10.127.0.3/32 \
          -i wg1 \
          -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -t raw -D PREROUTING \
          -d 10.127.0.3/32 \
          ! -i wg0 \
          -m addrtype ! --src-type LOCAL \
          -m comment --comment "block non-wg0/wg1 access to 10.127.0.3" \
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
        # Policy routing for marked packets
        ${pkgs.iproute2}/bin/ip rule add fwmark 0xca7f table 51821
        # Route everything from wg1 subnet via enp7s0
        ${pkgs.iproute2}/bin/ip rule add from 10.100.0.0/24 table 51821
        # Add default route for table 51821
        ${pkgs.iproute2}/bin/ip route add default dev enp7s0 table 51821
        # Allow marked packets through OUTPUT
        ${pkgs.iptables}/bin/iptables -t mangle -A OUTPUT -m mark --mark 0xca7f -j ACCEPT
        # NAT wg1 clients to enp7s0
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o enp7s0 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iproute2}/bin/ip rule del fwmark 0xca7f table 51821 || true
        ${pkgs.iproute2}/bin/ip rule del from 10.100.0.0/24 table 51821 || true
        ${pkgs.iproute2}/bin/ip route flush table 51821

        ${pkgs.iptables}/bin/iptables -t mangle -D OUTPUT -m mark --mark 0xca7f -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o enp7s0 -j MASQUERADE || true
      '';
      peers = [{
        allowedIPs = [ "10.100.0.2/32" ];
        publicKey = "JlHHaH807y8/qcHlgm0RBzrd1/NLkgzvQJCiqTlK6mU=";
      }];
      privateKeyFile = config.age.secrets.wireguard-down.path;
    };
  };
}