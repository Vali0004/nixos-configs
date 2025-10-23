{ config, lib, pkgs, ... }:

let
  netnsName = "container";
  vethHostIP4 = "192.168.100.1";
  vethNSIP4 = "192.168.100.2";
  vethHostIP6 = "fd00:100::1";
  vethNSIP6 = "fd00:100::2";
  vethName = "veth0"; # host side
  hostIF = "eth0";

  mkForward = port: target: {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      # Listen on both IPv4 and IPv6
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},reuseaddr,fork TCP:${target}:${toString port}";
      KillMode = "process";
      Restart = "always";
    };
  };

in {
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

  systemd.services."veth@${netnsName}" = {
    description = "veth pair for ${netnsName}";
    wantedBy = [ "network.target" ];
    preStart = ''
      ${pkgs.iproute2}/bin/ip netns add ${netnsName} || true
      ${pkgs.iproute2}/bin/ip link add ${vethName} type veth peer name veth1 netns ${netnsName}

      # IPv4 setup
      ${pkgs.iproute2}/bin/ip addr add ${vethHostIP4}/24 dev ${vethName}
      ${pkgs.iproute2}/bin/ip link set dev ${vethName} up
      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip addr add ${vethNSIP4}/24 dev veth1

      # IPv6 setup
      ${pkgs.iproute2}/bin/ip -6 addr add ${vethHostIP6}/64 dev ${vethName}
      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip -6 addr add ${vethNSIP6}/64 dev veth1

      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip link set dev veth1 up
      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip link set lo up

      # Enable default routes for IPv6 inside namespace
      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip -6 route add default via ${vethHostIP6} || true

      # NAT for IPv4
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${vethNSIP4}/24 -o ${hostIF} -j MASQUERADE
      # NAT for IPv6 (masquerade same way)
      ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s ${vethNSIP6}/64 -o ${hostIF} -j MASQUERADE || true
    '';
    preStop = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${vethNSIP4}/24 -o ${hostIF} -j MASQUERADE || true
      ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s ${vethNSIP6}/64 -o ${hostIF} -j MASQUERADE || true

      ${pkgs.iproute2}/bin/ip netns del ${netnsName} || true
      ${pkgs.iproute2}/bin/ip link delete ${vethName} || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Forward services
  systemd.services.forward80 = mkForward 80 vethNSIP4;
  systemd.services.forward443 = mkForward 443 vethNSIP4;
  systemd.services.forward3701 = mkForward 3701 vethNSIP4;

  systemd.services."wireguard-wg0".after = [ "veth@${netnsName}.service" ];

  networking.wireguard.interfaces.wg0 = {
    interfaceNamespace = netnsName;
    ips = [
      "fd00:127::3/128"
      "10.127.0.3/24"
    ];
    mtu = 1380;
    privateKeyFile = config.age.secrets.wireguard.path;
    peers = [{
      allowedIPs = [ "0.0.0.0/0" "::/0" ];
      endpoint = "74.208.44.130:51820";
      persistentKeepalive = 25;
      publicKey = "EjPutSj3y/DuPfz4F0W3PYz09Rk+XObW2Wh4W5cDrwA=";
    }];
  };
}
