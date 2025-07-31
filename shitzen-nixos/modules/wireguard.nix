{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.wireguard-tools ];
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      allowedIPsAsRoutes = false;
      ips = [ "10.127.0.3/32" ];
      privateKeyFile = config.age.secrets.wireguard.path;
      peers = [
        {
          publicKey = "EjPutSj3y/DuPfz4F0W3PYz09Rk+XObW2Wh4W5cDrwA=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "74.208.44.130:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  environment.etc."iproute2/rt_tables.d/100-wgroute.conf".text = "100 wgroute";

  #systemd.services.mark-vpn-traffic = {
  #  wantedBy = [ "multi-user.target" ];
  #  before = [ "network-online.target" ];
  #  serviceConfig = {
  #    Type = "oneshot";
  #    RemainAfterExit = true;
  #  };`
  #  script = ''
  #    IPT=${pkgs.iptables}/bin/iptables

  #    # Mark all outgoing packets from rtorrent with mark 1
  #    $IPT -t mangle -A OUTPUT -m owner --uid-owner rtorrent -j MARK --set-mark 1

  #    ## Mark all outgoing packets from nginx with mark 1
  #    #$IPT -t mangle -A OUTPUT -m owner --uid-owner nginx -j MARK --set-mark 1

  #    # Create a filter to reject any traffic not on loopback, or wg0
  #    $IPT -N OUT_FILTER || true
  #    $IPT -F OUT_FILTER

  #    $IPT -A OUT_FILTER -o wg0 -j RETURN
  #    $IPT -A OUT_FILTER -o lo -j RETURN
  #    $IPT -A OUT_FILTER -j REJECT

  #    ## Apply the fliter to nginx
  #    #$IPT -A OUTPUT -m owner --uid-owner nginx -j OUT_FILTER

  #    # Apply the fliter to rtorrent
  #    $IPT -A OUTPUT -m owner --uid-owner rtorrent -j OUT_FILTER
  #  '';
  #  preStop = ''
  #    IPT=${pkgs.iptables}/bin/iptables

  #    # Remove rtorrent mark
  #    $IPT -t mangle -D OUTPUT -m owner --uid-owner rtorrent -j MARK --set-mark 1 || true

  #    ## Remove nginx mark
  #    #$IPT -t mangle -D OUTPUT -m owner --uid-owner nginx -j MARK --set-mark 1 || true

  #    # Remove rtorrent filter
  #    $IPT -D OUTPUT -m owner --uid-owner rtorrent -j OUT_FILTER || true

  #    ## Remove nginx filter
  #    #$IPT -D OUTPUT -m owner --uid-owner nginx -j OUT_FILTER || true

  #    # Cleanup filter
  #    $IPT -F OUT_FILTER || true
  #    $IPT -X OUT_FILTER || true
  #  '';
  #};

  systemd.network.networks."30-wg0" = {
    matchConfig.Name = "wg0";
    address = [ "10.127.0.3/24" ];
    routingPolicyRules = [{
      routingPolicyRuleConfig = {
        FirewallMark = 1;
        Table = 100;
        Priority = 100;
      };
    }];
  };
}