{ config, lib, pkgs, ... }:

let
  netnsName = "container";
  vethHostIP = "192.168.100.1";
  vethNSIP = "192.168.100.2";
  vethName = "veth0"; # host side
  hostIF = "eth0";
  mkForward = port: target: {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},reuseaddr,fork TCP4:${target}:${toString port}";
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
      ${pkgs.iproute2}/bin/ip netns add ${netnsName}
      ${pkgs.iproute2}/bin/ip link add ${vethName} type veth peer name veth1 netns ${netnsName}

      ${pkgs.iproute2}/bin/ip addr add ${vethHostIP}/24 dev ${vethName}
      ${pkgs.iproute2}/bin/ip link set dev ${vethName} up
      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip addr add ${vethNSIP}/24 dev veth1

      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip link set dev veth1 up

      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip link set lo up

      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${vethNSIP}/24 -o ${hostIF} -j MASQUERADE
    '';
    preStop = ''
      ${pkgs.iproute2}/bin/ip netns del ${netnsName}
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${vethNSIP}/24 -o ${hostIF} -j MASQUERADE
      ${pkgs.iproute2}/bin/ip link delete ${vethName} || true
      ${pkgs.iproute2}/bin/ip netns exec ${netnsName} ${pkgs.iproute2}/bin/ip link delete veth0 || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  systemd.services.forward80 = mkForward 80 "192.168.100.2";
  systemd.services.forward443 = mkForward 443 "192.168.100.2";
  systemd.services.forward3701 = mkForward 3701 "192.168.100.2";
  systemd.services."wireguard-wg0".serviceConfig.After = [ "veth@${netnsName}.service" ];

  networking.wireguard = {
    interfaces = {
      wg0 = {
        interfaceNamespace = netnsName;
        ips = [ "10.127.0.3/24" ];
        mtu = 1380;
        privateKeyFile = config.age.secrets.wireguard.path;
        peers = [{
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
          endpoint = "74.208.44.130:51820";
          persistentKeepalive = 25;
          publicKey = "EjPutSj3y/DuPfz4F0W3PYz09Rk+XObW2Wh4W5cDrwA=";
        }];
      };
    };
  };
}
