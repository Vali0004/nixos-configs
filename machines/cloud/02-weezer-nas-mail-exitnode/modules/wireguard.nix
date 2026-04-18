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
      "10.10.0.1/24"
      "fd00:10::1/64"
    ];
    listenPort = 51820;
    mtu = 1420;
    postSetup = ''
      ${iptables}/bin/iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -o eth0 -j MASQUERADE
      ${iptables}/bin/ip6tables -t nat -A POSTROUTING -s fd00:10::/64 -o eth0 -j MASQUERADE

      for x in 25 143 465 587 993 995; do
        ${iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport ''${x} -j DNAT --to-destination 10.10.0.3:''${x} || true
        ${iptables}/bin/ip6tables -t nat -A PREROUTING -i eth0 -p tcp --dport ''${x} -j DNAT --to-destination fd00:10::3:''${x} || true
      done

      ${iptables}/bin/iptables -A FORWARD -s 10.10.0.0/24 -j ACCEPT || true
      ${iptables}/bin/iptables -A FORWARD -d 10.10.0.0/24 -j ACCEPT || true
      ${iptables}/bin/ip6tables -A FORWARD -s fd00:10::/64 -j ACCEPT || true
      ${iptables}/bin/ip6tables -A FORWARD -d fd00:10::/64 -j ACCEPT || true

      ${iptables}/bin/iptables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
      ${iptables}/bin/ip6tables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
    '';
    postShutdown = ''
      ${iptables}/bin/iptables -t nat -D POSTROUTING -s 10.10.0.0/24 -o eth0 -j MASQUERADE || true
      ${iptables}/bin/ip6tables -t nat -D POSTROUTING -s fd00:10::/64 -o eth0 -j MASQUERADE

      for x in 25 143 465 587 993 995; do
        ${iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport ''${x} -j DNAT --to-destination 10.10.0.3:''${x} || true
        ${iptables}/bin/ip6tables -t nat -D PREROUTING -i eth0 -p tcp --dport ''${x} -j DNAT --to-destination 10.10.0.3:''${x} || true
      done

      ${iptables}/bin/iptables -D FORWARD -s 10.10.0.0/24 -j ACCEPT || true
      ${iptables}/bin/iptables -D FORWARD -d 10.10.0.0/24 -j ACCEPT || true
      ${iptables}/bin/ip6tables -D FORWARD -s fd00:10::/64 -j ACCEPT || true
      ${iptables}/bin/ip6tables -D FORWARD -d fd00:10::/64 -j ACCEPT || true

      ${iptables}/bin/iptables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
      ${iptables}/bin/ip6tables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
    '';
    privateKeyFile = config.age.secrets.wireguard-mail-server.path;
    #peers = [{
    #  allowedIPs = [
    #    "10.10.0.3/32"
    #    "fd00:10::3/128"
    #  ];
    #  publicKey = "TekfTYyHo+PsZRFLHopuw3/aBFe6/H3+ZaTLIg4mg24=";
    #}];
  };
}