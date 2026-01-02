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
    internalInterfaces = [ "wg1" ];
  };

  networking.firewall.allowedUDPPorts = lib.mkIf config.networking.wireguard.enable [
    config.networking.wireguard.interfaces.wg1.listenPort
  ];

  networking.wireguard.enable = true;
  networking.wireguard.interfaces.wg1 = {
    ips = [
      "10.0.10.1/24"
      "fd10:0::1/64"
    ];
    listenPort = 51821;
    postSetup = ''
      ${iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.10.0/24 -o eth0 -j MASQUERADE
      ${iptables}/bin/ip6tables -t nat -A POSTROUTING -s fd10:0::/64 -o eth0 -j MASQUERADE

      ${iptables}/bin/iptables -A FORWARD -s 10.0.10.0/24 -j ACCEPT || true
      ${iptables}/bin/iptables -A FORWARD -d 10.0.10.0/24 -j ACCEPT || true
      ${iptables}/bin/ip6tables -A FORWARD -s fd10:0::/64 -j ACCEPT || true
      ${iptables}/bin/ip6tables -A FORWARD -d fd10:0::/64 -j ACCEPT || true

      ${iptables}/bin/iptables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
      ${iptables}/bin/ip6tables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
    '';
    postShutdown = ''
      ${iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.10.0/24 -o eth0 -j MASQUERADE || true
      ${iptables}/bin/ip6tables -t nat -D POSTROUTING -s 1/64 -o eth0 -j MASQUERADE

      ${iptables}/bin/iptables -D FORWARD -s 10.0.10.0/24 -j ACCEPT || true
      ${iptables}/bin/iptables -D FORWARD -d 10.0.10.0/24 -j ACCEPT || true
      ${iptables}/bin/ip6tables -D FORWARD -s fd10:0::/64 -j ACCEPT || true
      ${iptables}/bin/ip6tables -D FORWARD -d fd10:0::/64 -j ACCEPT || true

      ${iptables}/bin/iptables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
      ${iptables}/bin/ip6tables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
    '';
    privateKeyFile = "/root/wireguard-keys/privatekey";
    peers = [{
      allowedIPs = [
        "10.0.10.2/32"
        "fd10:0::2/128"
      ];
      publicKey = "6RNJSvT1tQ5HalACGgciaxJujQz/3claRHKOunBsDX4=";
    }];
  };
}
