{ config
, lib
, pkgs
, ... }:

let
  iptables = pkgs.iptables;
in {
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall.allowedUDPPorts = lib.mkIf config.networking.wireguard.enable [
    config.networking.wireguard.interfaces.wg0.listenPort
  ];

  networking.wireguard.enable = true;
  networking.wireguard.interfaces.wg0 = {
    ips = [
      "10.127.0.1/24"
      "fd00:127::1/64"
    ];
    listenPort = 51820;
    postSetup = ''
      ${iptables}/bin/iptables -t nat -A POSTROUTING -s 10.127.0.0/24 -o eth0 -j MASQUERADE
      ${iptables}/bin/ip6tables -t nat -A POSTROUTING -s fd00:127::/64 -o eth0 -j MASQUERADE

      for x in 25 80 143 465 587 993 995 3700 4100 6697 8080; do
        ${iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport ''${x} -j DNAT --to-destination 10.127.0.3:''${x} || true
        ${iptables}/bin/ip6tables -t nat -A PREROUTING -i eth0 -p udp --dport ''${x} -j DNAT --to-destination fd00:127::3:''${x} || true
      done
      for x in 37000 4101 6990; do
        ${iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p udp --dport ''${x} -j DNAT --to-destination 10.127.0.3:''${x} || true
        ${iptables}/bin/ip6tables -t nat -A PREROUTING -i eth0 -p udp --dport ''${x} -j DNAT --to-destination fd00:127::3:''${x} || true
      done

      # Forward node exporter for shitzen as 9101 (comes from 9100)
      ${iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 9101 -j DNAT --to-destination 10.127.0.3:9100 || true
      ${iptables}/bin/ip6tables -t nat -A PREROUTING -i eth0 -p tcp --dport 9101 -j DNAT --to-destination fd00:127::3:9100 || true

      ${iptables}/bin/iptables -A FORWARD -s 10.127.0.0/24 -j ACCEPT || true
      ${iptables}/bin/iptables -A FORWARD -d 10.127.0.0/24 -j ACCEPT || true
      ${iptables}/bin/ip6tables -A FORWARD -s fd00:127::/64 -j ACCEPT || true
      ${iptables}/bin/ip6tables -A FORWARD -d fd00:127::/64 -j ACCEPT || true

      ${iptables}/bin/iptables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
      ${iptables}/bin/ip6tables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
    '';
    postShutdown = ''
      ${iptables}/bin/iptables -t nat -D POSTROUTING -s 10.127.0.0/24 -o eth0 -j MASQUERADE || true
      ${iptables}/bin/ip6tables -t nat -D POSTROUTING -s fd00:127::/64 -o eth0 -j MASQUERADE

      for x in 25 80 465 587 993 995 3700 4100 6697 8080; do
        ${iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport ''${x} -j DNAT --to-destination 10.127.0.3:''${x} || true
        ${iptables}/bin/ip6tables -t nat -D PREROUTING -i eth0 -p tcp --dport ''${x} -j DNAT --to-destination 10.127.0.3:''${x} || true
      done
      for x in 37000 4101 6990; do
        ${iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p udp --dport ''${x} -j DNAT --to-destination 10.127.0.3:''${x} || true
        ${iptables}/bin/ip6tables -t nat -D PREROUTING -i eth0 -p udp --dport ''${x} -j DNAT --to-destination fd00:127::3:''${x} || true
      done
      ${iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 9101 -j DNAT --to-destination 10.127.0.3:9100 || true
      ${iptables}/bin/ip6tables -t nat -D PREROUTING -i eth0 -p tcp --dport 9101 -j DNAT --to-destination fd00:127::3:9100 || true

      ${iptables}/bin/iptables -D FORWARD -s 10.127.0.0/24 -j ACCEPT || true
      ${iptables}/bin/iptables -D FORWARD -d 10.127.0.0/24 -j ACCEPT || true
      ${iptables}/bin/ip6tables -D FORWARD -s fd00:127::/64 -j ACCEPT || true
      ${iptables}/bin/ip6tables -D FORWARD -d fd00:127::/64 -j ACCEPT || true

      ${iptables}/bin/iptables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
      ${iptables}/bin/ip6tables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
    '';
    privateKeyFile = config.age.secrets.wireguard-server.path;
    peers = [{
      allowedIPs = [
        "10.127.0.3/32"
        "fd00:127::3/128"
      ];
      publicKey = "TekfTYyHo+PsZRFLHopuw3/aBFe6/H3+ZaTLIg4mg24=";
    }];
  };
}