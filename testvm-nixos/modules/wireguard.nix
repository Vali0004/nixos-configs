{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };

  networking.wireguard.enable = true;
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.127.0.1/24" ];
    listenPort = 51820;
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.127.0.0/24 -o eth0 -j MASQUERADE

      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.127.0.0/24 -o eth0 -p udp -j MASQUERADE

      ${pkgs.iptables}/bin/iptables -A FORWARD -s 10.127.0.0/24 -p tcp -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -d 10.127.0.0/24 -p tcp -j ACCEPT

      ${pkgs.iptables}/bin/iptables -A FORWARD -s 10.127.0.0/24 -p udp -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -d 10.127.0.0/24 -p udp -j ACCEPT

      ${pkgs.iptables}/bin/iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -s 10.127.0.0/24 -j ACCEPT

      if [ -f /etc/wireguard/wg0.peers.conf ]; then
        ${pkgs.wireguard-tools}/bin/wg addconf wg0 /etc/wireguard/wg0.peers.conf
      fi
    '';
    postShutdown = ''
      ${pkgs.wireguard-tools}/bin/wg showconf wg0 | ${pkgs.gawk}/bin/awk '/^\[Peer\]/{f=1} f' > /etc/wireguard/wg0.peers.conf
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.127.0.0/24 -o eth0 -j MASQUERADE

      ${pkgs.iptables}/bin/iptables -D FORWARD -s 10.127.0.0/24 -p tcp -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -d 10.127.0.0/24 -p tcp -j ACCEPT

      ${pkgs.iptables}/bin/iptables -D FORWARD -s 10.127.0.0/24 -p udp -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -d 10.127.0.0/24 -p udp -j ACCEPT

      ${pkgs.iptables}/bin/iptables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -s 10.127.0.0/24 -j ACCEPT
    '';
    privateKeyFile = config.age.secrets.wireguard-server.path;
    peers = [

    ];
  };
}