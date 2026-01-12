{ config
, pkgs
, ... }:

let
  iptables = pkgs.iptables;
  lanIf = config.router.bridgeInterface;
  wanIf = config.router.wanInterface;
  lanCidr = "${config.router.lanSubnet}.0/24";
  lanV6Cidr = "2601:406:8100:91D8::/64";
  wanIp = "76.112.236.206";
in {
  networking.nat = {
    enable = true;
    externalInterface = wanIf;
    internalInterfaces = [ lanIf ];
    forwardPorts = [
      {
        # ssh
        destination = "${config.router.lanSubnet}.4:22";
        proto = "tcp";
        sourcePort = 2222;
        loopbackIPs = [ wanIp ];
      }
      {
        # iperf2
        destination = "${config.router.lanSubnet}.4:5201";
        proto = "tcp";
        sourcePort = 5201;
      }
      {
        # WireGuard
        destination = "${config.router.lanSubnet}.4:443";
        proto = "udp";
        sourcePort = 443;
        loopbackIPs = [ wanIp ];
      }
      {
        # WireGuard Internal
        destination = "${config.router.lanSubnet}.4:51821";
        proto = "udp";
        sourcePort = 51821;
        loopbackIPs = [ wanIp ];
      }
      {
        # HTTP
        destination = "${config.router.lanSubnet}.2:80";
        proto = "tcp";
        sourcePort = 80;
        loopbackIPs = [ wanIp ];
      }
      {
        # HTTPS
        destination = "${config.router.lanSubnet}.2:443";
        proto = "tcp";
        sourcePort = 443;
        loopbackIPs = [ wanIp ];
      }
    ];
  };

  networking.firewall = {
    extraCommands = ''
      # Allow LAN -> WAN
      ${iptables}/bin/iptables -C FORWARD -i ${lanIf} -o ${wanIf} -j ACCEPT 2>/dev/null || \
      ${iptables}/bin/iptables -A FORWARD -i ${lanIf} -o ${wanIf} -j ACCEPT
      ${iptables}/bin/ip6tables -C FORWARD -i ${lanIf} -o ${wanIf} -j ACCEPT 2>/dev/null || \
      ${iptables}/bin/ip6tables -A FORWARD -i ${lanIf} -o ${wanIf} -j ACCEPT

      # Allow established/related back WAN -> LAN
      ${iptables}/bin/iptables -C FORWARD -i ${wanIf} -o ${lanIf} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
      ${iptables}/bin/iptables -A FORWARD -i ${wanIf} -o ${lanIf} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      ${iptables}/bin/ip6tables -C FORWARD -i ${wanIf} -o ${lanIf} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
      ${iptables}/bin/ip6tables -A FORWARD -i ${wanIf} -o ${lanIf} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

      # If for some reason networking.nat doesn't add masquerade, force it:
      ${iptables}/bin/iptables -t nat -C POSTROUTING -s ${lanCidr} -o ${wanIf} -j MASQUERADE 2>/dev/null || \
      ${iptables}/bin/iptables -t nat -A POSTROUTING -s ${lanCidr} -o ${wanIf} -j MASQUERADE
      ${iptables}/bin/ip6tables -t nat -C POSTROUTING -s ${lanV6Cidr} -o ${wanIf} -j MASQUERADE 2>/dev/null || \
      ${iptables}/bin/ip6tables -t nat -A POSTROUTING -s ${lanV6Cidr} -o ${wanIf} -j MASQUERADE
    '';
    extraStopCommands = ''
      ${iptables}/bin/iptables -t nat -D POSTROUTING -s ${lanCidr} -o ${wanIf} -j MASQUERADE 2>/dev/null || true
      ${iptables}/bin/ip6tables -t nat -D POSTROUTING -s ${lanV6Cidr} -o ${wanIf} -j MASQUERADE 2>/dev/null || true

      ${iptables}/bin/iptables -D FORWARD -i ${lanIf} -o ${wanIf} -j ACCEPT 2>/dev/null || true
      ${iptables}/bin/ip6tables -D FORWARD -i ${lanIf} -o ${wanIf} -j ACCEPT 2>/dev/null || true

      ${iptables}/bin/iptables -D FORWARD -i ${wanIf} -o ${lanIf} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
      ${iptables}/bin/ip6tables -D FORWARD -i ${wanIf} -o ${lanIf} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
    '';
  };
}