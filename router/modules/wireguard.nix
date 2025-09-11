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

      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 25 -j DNAT --to-destination 10.127.0.3:25
      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 465 -j DNAT --to-destination 10.127.0.3:465
      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 587 -j DNAT --to-destination 10.127.0.3:587
      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 993 -j DNAT --to-destination 10.127.0.3:993
      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 995 -j DNAT --to-destination 10.127.0.3:995
      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 3700 -j DNAT --to-destination 10.127.0.3:3700
      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 4100 -j DNAT --to-destination 10.127.0.3:4100
      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 6667 -j DNAT --to-destination 10.127.0.3:6667
      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 6697 -j DNAT --to-destination 10.127.0.3:6697
      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 9100 -j DNAT --to-destination 10.127.0.3:9100
      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p udp --dport 3700 -j DNAT --to-destination 10.127.0.3:3700
      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p udp --dport 4101 -j DNAT --to-destination 10.127.0.3:4101
      ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i eth0 -p udp --dport 6990 -j DNAT --to-destination 10.127.0.3:6990

      ${pkgs.iptables}/bin/iptables -A FORWARD -s 10.127.0.0/24 -p tcp -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -d 10.127.0.0/24 -p tcp -j ACCEPT

      ${pkgs.iptables}/bin/iptables -A FORWARD -s 10.127.0.0/24 -p udp -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -d 10.127.0.0/24 -p udp -j ACCEPT

      ${pkgs.iptables}/bin/iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -s 10.127.0.0/24 -j ACCEPT
    '';
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.127.0.0/24 -o eth0 -j MASQUERADE

      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 25 -j DNAT --to-destination 10.127.0.3:25
      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 465 -j DNAT --to-destination 10.127.0.3:465
      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 587 -j DNAT --to-destination 10.127.0.3:587
      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 993 -j DNAT --to-destination 10.127.0.3:993
      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 995 -j DNAT --to-destination 10.127.0.3:995
      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 3700 -j DNAT --to-destination 10.127.0.3:3700
      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 4100 -j DNAT --to-destination 10.127.0.3:4100
      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 6667 -j DNAT --to-destination 10.127.0.3:6667
      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 6697 -j DNAT --to-destination 10.127.0.3:6697
      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 9100 -j DNAT --to-destination 10.127.0.3:9100
      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p udp --dport 3700 -j DNAT --to-destination 10.127.0.3:3700
      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p udp --dport 4101 -j DNAT --to-destination 10.127.0.3:4101
      ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i eth0 -p udp --dport 6990 -j DNAT --to-destination 10.127.0.3:6990

      ${pkgs.iptables}/bin/iptables -D FORWARD -s 10.127.0.0/24 -p tcp -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -d 10.127.0.0/24 -p tcp -j ACCEPT

      ${pkgs.iptables}/bin/iptables -D FORWARD -s 10.127.0.0/24 -p udp -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -d 10.127.0.0/24 -p udp -j ACCEPT

      ${pkgs.iptables}/bin/iptables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -s 10.127.0.0/24 -j ACCEPT
    '';
    privateKeyFile = config.age.secrets.wireguard-server.path;
    peers = [{
      allowedIPs = [ "10.127.0.3/32" ];
      publicKey = "TekfTYyHo+PsZRFLHopuw3/aBFe6/H3+ZaTLIg4mg24=";
    }];
  };
}