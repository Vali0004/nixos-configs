{ config
, lib
, pkgs
, ... }:

let
  ip4 = "${pkgs.iptables}/bin/iptables";
  ip6 = "${pkgs.iptables}/bin/ip6tables";

  # shared by postSetup and postShutdown so the add and delete sides can't drift apart
  rules = [
    { bin = ip4; rule = "-t nat"; args = "POSTROUTING -s 10.0.10.0/24 -o enp3s0 -j MASQUERADE"; }
    { bin = ip6; rule = "-t nat"; args = "POSTROUTING -s fd10:0::/64 -o enp3s0 -j MASQUERADE"; }
    { bin = ip4; rule = "-t filter"; args = "FORWARD -s 10.0.10.0/24 -j ACCEPT"; }
    { bin = ip4; rule = "-t filter"; args = "FORWARD -d 10.0.10.0/24 -j ACCEPT"; }
    { bin = ip6; rule = "-t filter"; args = "FORWARD -s fd10:0::/64 -j ACCEPT"; }
    { bin = ip6; rule = "-t filter"; args = "FORWARD -d fd10:0::/64 -j ACCEPT"; }
  ];
in {
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "enp3s0";
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
    # each rule is checked with -C first so restarts never stack duplicates
    postSetup = lib.concatMapStringsSep "\n" (r: "${r.bin} ${r.rule} -C ${r.args} || ${r.bin} ${r.rule} -A ${r.args}") rules;
    postShutdown = lib.concatMapStringsSep "\n" (r: "while ${r.bin} ${r.rule} -D ${r.args} 2>/dev/null; do :; done") rules;
    privateKeyFile = "/root/wireguard-keys/privatekey";
    peers = [
      {
        allowedIPs = [
          "10.0.10.2/32"
          "fd10:0::2/128"
        ];
        publicKey = "6RNJSvT1tQ5HalACGgciaxJujQz/3claRHKOunBsDX4=";
      }
      {
        allowedIPs = [
          "10.0.10.3/32"
          "fd10:0::3/128"
        ];
        publicKey = "y/bR//Gd/goJxWWyeH0N1hOBM4lP/k+FLGeibCUBIhY=";
      }
      {
        allowedIPs = [
          "10.0.10.4/32"
          "fd10:0::4/128"
        ];
        publicKey = "7WiqaOz9ipOhNpHp9mWvEhm2F/Rn7BEtc9U17t2LeAA=";
      }
    ];
  };
}