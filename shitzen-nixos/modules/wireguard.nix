{ config, lib, pkgs, ... }:

let
  netnsName = "container";
  vethHostIP = "192.168.100.1";
  vethNSIP = "192.168.100.2";
  vethName = "veth0"; # host side
  hostIF = "eth0";
in
{
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking = {
    networkmanager.unmanaged = [ "interface-name:wg0" ];

    firewall = {
      allowPing = true;
      allowedUDPPorts = [ 51820 ];
      checkReversePath = false;
      interfaces.veth0 = {
        allowedTCPPortRanges = [{ from = 0; to = 65535; }];
      };
    };
  };

  systemd.services."netns@${netnsName}" = {
    description = "Network namespace ${netnsName}";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip netns add ${netnsName}";
      ExecStop = "${pkgs.iproute2}/bin/ip netns del ${netnsName}";
    };
  };

  systemd.services."veth@${netnsName}" = {
    description = "veth pair for ${netnsName}";
    after = [ "netns@${netnsName}.service" ];
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      ${pkgs.iproute2}/bin/ip link add ${vethName} type veth peer name veth1 netns ${netnsName}

      ${pkgs.iproute2}/bin/ip addr add ${vethHostIP}/24 dev ${vethName}
      ${pkgs.iproute2}/bin/ip link set dev ${vethName} up
      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip addr add ${vethNSIP}/24 dev veth1

      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip link set dev veth1 up

      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip link set lo up

      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${vethNSIP}/24 -o ${hostIF} -j MASQUERADE
    '';
    preStop = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${vethNSIP}/24 -o ${hostIF} -j MASQUERADE
      ${pkgs.iproute2}/bin/ip link delete ${vethName} || true
      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip link delete veth0 || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  systemd.services."wireguard-wg0".serviceConfig.Requires = [ "veth@${netnsName}.service" ];
  systemd.services."wireguard-wg0".serviceConfig.After = [ "veth@${netnsName}.service" ];

  networking.wireguard = {
    interfaces = {
      wg0 = {
        interfaceNamespace = netnsName;
        ips = [ "10.127.0.3/24" ];
        mtu = 1380;
        privateKeyFile = config.age.secrets.wireguard.path;
        peers = [{
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "74.208.44.130:51820";
          persistentKeepalive = 25;
          publicKey = "EjPutSj3y/DuPfz4F0W3PYz09Rk+XObW2Wh4W5cDrwA=";
        }];
        preSetup = ''
          # connmark restore/save
          ${pkgs.iptables}/bin/iptables -t mangle -A PREROUTING -p udp -m comment --comment "wg-quick(8) rule for wg0" \
            -j CONNMARK --restore-mark --nfmask 0xffffffff --ctmask 0xffffffff
          ${pkgs.iptables}/bin/iptables -t mangle -A POSTROUTING -p udp -m mark --mark 0xca6c -m comment --comment "wg-quick(8) rule for wg0" \
            -j CONNMARK --save-mark --nfmask 0xffffffff --ctmask 0xffffffff

          # kill switch
          ${pkgs.iptables}/bin/iptables -t raw -A PREROUTING -d 10.127.0.3/32 ! -i wg0 -m addrtype ! --src-type LOCAL \
            -m comment --comment "wg-quick(8) rule for wg0" -j DROP

          # allow wg0 traffic through nixos-fw
          ${pkgs.iptables}/bin/iptables -A nixos-fw -i wg0 -p tcp -j nixos-fw-accept
        '';
        preShutdown = ''
          ${pkgs.iptables}/bin/iptables -t mangle -D PREROUTING -p udp -m comment --comment "wg-quick(8) rule for wg0" \
            -j CONNMARK --restore-mark --nfmask 0xffffffff --ctmask 0xffffffff
          ${pkgs.iptables}/bin/iptables -t mangle -D POSTROUTING -p udp -m mark --mark 0xca6c -m comment --comment "wg-quick(8) rule for wg0" \
            -j CONNMARK --save-mark --nfmask 0xffffffff --ctmask 0xffffffff
          ${pkgs.iptables}/bin/iptables -t raw -D PREROUTING -d 10.127.0.3/32 ! -i wg0 -m addrtype ! --src-type LOCAL \
            -m comment --comment "wg-quick(8) rule for wg0" -j DROP
          ${pkgs.iptables}/bin/iptables -D nixos-fw -i wg0 -p tcp -j nixos-fw-accept
        '';
      };
    };
  };
}
