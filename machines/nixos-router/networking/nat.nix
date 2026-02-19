{ config
, lib
, pkgs
, ... }:

let
  cfg = config.router;
  iptables = pkgs.iptables;
  toxIf = "tox_master0";
  wanIp = "76.112.236.206";
in {
  networking.nat = {
    enable = true;
    externalInterface = cfg.wanInterface;
    internalInterfaces = [ cfg.bridgeInterface ];
    forwardPorts = [
      {
        # ssh
        destination = "${cfg.lanSubnet}.4:22";
        proto = "tcp";
        sourcePort = 2222;
        loopbackIPs = [ wanIp ];
      }
      {
        # iperf2
        destination = "${cfg.lanSubnet}.4:5201";
        proto = "tcp";
        sourcePort = 5201;
      }
      {
        # WireGuard
        destination = "${cfg.lanSubnet}.4:51820";
        proto = "udp";
        sourcePort = 51820;
        loopbackIPs = [ wanIp ];
      }
      {
        # WireGuard Internal
        destination = "${cfg.lanSubnet}.4:51821";
        proto = "udp";
        sourcePort = 51821;
        loopbackIPs = [ wanIp ];
      }
    ];
  };

  networking.firewall = {
    extraCommands = ''
      # Allow LAN -> WAN
      ${iptables}/bin/iptables -C FORWARD -i ${cfg.bridgeInterface} -o ${cfg.wanInterface} -j ACCEPT 2>/dev/null || \
      ${iptables}/bin/iptables -A FORWARD -i ${cfg.bridgeInterface} -o ${cfg.wanInterface} -j ACCEPT

      # Allow established/related back WAN -> LAN
      ${iptables}/bin/iptables -C FORWARD -i ${cfg.wanInterface} -o ${cfg.bridgeInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
      ${iptables}/bin/iptables -A FORWARD -i ${cfg.wanInterface} -o ${cfg.bridgeInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

      # If for some reason networking.nat doesn't add masquerade, force it:
      ${iptables}/bin/iptables -t nat -C POSTROUTING -s ${cfg.lanSubnet}.0/24 -o ${cfg.wanInterface} -j MASQUERADE 2>/dev/null || \
      ${iptables}/bin/iptables -t nat -A POSTROUTING -s ${cfg.lanSubnet}.0/24 -o ${cfg.wanInterface} -j MASQUERADE
    '';
    extraStopCommands = ''
      ${iptables}/bin/iptables -t nat -D POSTROUTING -s ${cfg.lanSubnet}.0/24 -o ${cfg.wanInterface} -j MASQUERADE 2>/dev/null || true
      ${iptables}/bin/iptables -D FORWARD -i ${cfg.bridgeInterface} -o ${cfg.wanInterface} -j ACCEPT 2>/dev/null || true
      ${iptables}/bin/iptables -D FORWARD -i ${cfg.wanInterface} -o ${cfg.bridgeInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
    '';
  };
}