{ config
, lib
, pkgs
, ... }:

let
  cfg = config.router;
  wan1 = cfg.wanInterface;
  wan2 = cfg.wan2Interface;

  # Hosts pinged to decide whether an uplink is actually carrying traffic.
  # Anycast resolvers: reachable from every ISP, and never all down at once.
  probeTargets = [ "1.1.1.1" "8.8.8.8" "9.9.9.9" ];

  # Link-up is not the same as internet-up: the Comcast modem happily holds
  # carrier while the ISP side is dead. So we probe out of the interface with
  # SO_BINDTODEVICE (ping -I <ifname>), which ignores the routing table, and
  # demote wan1's default route metric when the probes stop answering. The
  # kernel then prefers wan2's default route, which is always installed.
  failoverScript = pkgs.writeShellApplication {
    name = "wan-failover";
    runtimeInputs = with pkgs; [ iproute2 iputils conntrack-tools ];
    text = ''
      probe() {
        local dev="$1" target
        for target in ${lib.concatStringsSep " " probeTargets}; do
          if ping -q -n -c 2 -W 2 -I "$dev" "$target" >/dev/null 2>&1; then
            return 0
          fi
        done
        return 1
      }

      # Current default route via $1, as an "via X dev Y" fragment, or empty.
      default_via() {
        ip -4 route show default dev "$1" \
          | awk '/^default/ { for (i=1;i<NF;i++) if ($i=="via") print $(i+1); exit }'
      }

      state_file=/run/wan-failover.state
      previous=$(cat "$state_file" 2>/dev/null || echo unknown)

      gw1=$(default_via ${wan1})

      if [ -n "$gw1" ] && probe ${wan1}; then
        current=primary
        metric=${toString cfg.wanMetric}
      else
        current=fallback
        metric=${toString cfg.wanDemotedMetric}
      fi

      # Re-assert the metric every run: dhcpcd reinstalls the route at its
      # configured metric on every lease renewal, which would silently undo a
      # demotion. Cheap enough to just replace unconditionally.
      if [ -n "$gw1" ]; then
        ip -4 route replace default via "$gw1" dev ${wan1} metric "$metric"
      fi

      if [ "$current" != "$previous" ]; then
        echo "wan failover: $previous -> $current"
        # Flows are NAT'd to the old uplink's source address and are now
        # unroutable. Drop them so clients re-establish through the new WAN.
        conntrack -F || true
      fi

      echo "$current" > "$state_file"
    '';
  };
in lib.mkIf (wan2 != null) {
  # The nat module only masquerades out externalInterface (wan1), which is
  # correct - forwardPorts and loopbackIPs are meaningless behind the 5G
  # box's CGNAT. wan2 needs its own masquerade, in its own table so it does
  # not fight with nixos-nat.
  networking.nftables.tables.wan2-nat = {
    family = "ip";
    content = ''
      chain postrouting {
        type nat hook postrouting priority srcnat + 10; policy accept;
        oifname "${wan2}" masquerade
      }
    '';
  };

  networking.firewall.extraForwardRules = ''
    iifname "${cfg.bridgeInterface}" oifname "${wan2}" accept
    iifname "${wan2}" oifname "${cfg.bridgeInterface}" ct state established,related accept
  '';

  # Asymmetry between the two uplinks is normal here; strict reverse path
  # filtering would drop probe replies during a switchover.
  boot.kernel.sysctl."net.ipv4.conf.${wan2}.rp_filter" = 0;

  systemd.services.wan-failover = {
    description = "Pick the healthy WAN uplink";
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe failoverScript;
    };
  };

  systemd.timers.wan-failover = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "15s";
      AccuracySec = "1s";
    };
  };
}
