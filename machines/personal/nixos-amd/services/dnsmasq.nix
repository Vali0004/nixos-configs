{ pkgs
, inputs
, ... }:

let
  sys = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({ config, pkgs, lib, modulesPath, ... }: {
        imports = [
          (modulesPath + "/installer/netboot/netboot-minimal.nix")
        ];
        config = {
          services.getty.autologinUser = lib.mkForce "root";
          users.users.root.openssh.authorizedKeys.keys = (import ../../../../ssh_keys_personal.nix);

          system.stateVersion = config.system.nixos.release;
        };
      })
    ];
  };

  run-pixiecore = let
    build = sys.config.system.build;
  in pkgs.writeScriptBin "run-pixiecore" ''
    exec ${pkgs.pixiecore}/bin/pixiecore \
      boot ${build.kernel}/bzImage ${build.netbootRamdisk}/initrd \
      --cmdline "init=${build.toplevel}/init loglevel=4" \
      --debug --dhcp-no-bind \
      --port 64172 --status-port 64172 "$@"
  '';

  sharedInternetDevice = "wlan0";
  # USB gigabit NIC facing the Raspberry Pi 3B+. It shares a ganged hub with the
  # Pi's power, so it disappears and returns on every board power cycle.
  bindingDevice = "enp19s0u4u3";

  serverAddress = "192.168.66.1";
  tftpRoot = "/srv/tftp";
in {
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      bind-interfaces = true;

      interface = [ bindingDevice ];
      listen-address = [ serverAddress ];

      dhcp-authoritative = true;
      dhcp-range = [
        "192.168.66.100,192.168.66.200,12h"
        "2001:db8:1::1000,2001:db8:1::2000,64,12h"
        "::,constructor:${bindingDevice},ra-stateless,ra-names,64,2h"
      ];

      dhcp-option = [
        "option:dns-server,1.1.1.1,8.8.8.8"
        "option6:dns-server,[2606:4700:4700::1111],[2001:4860:4860::8888]"
      ];

      dhcp-boot = "bootcode.bin,,${serverAddress}";
      dhcp-option-force = [ "66,${serverAddress}" ];
      pxe-service = [ ''0,"Raspberry Pi Boot"'' ];
      dhcp-reply-delay = 1;

      enable-tftp = true;
      tftp-root = tftpRoot;
      tftp-no-blocksize = true;

      log-dhcp = true;

      # Disable resolv.conf parsing, as we assign our own via DHCP.
      no-resolv = true;

      enable-ra = true;
      ra-param = [ "${bindingDevice},1800" ]; # M=1800, O=0

      port = 0; # Disable DNS fully
    };
  };

  systemd.tmpfiles.rules = [
    "d ${tftpRoot} 0755 root root -"
  ];

  environment.systemPackages = [
    run-pixiecore
  ];

  networking = {
    networkmanager.unmanaged = [
      "interface-name:${bindingDevice}"
    ];
    interfaces = {
      ${bindingDevice} = {
        ipv4 = {
          addresses = [{
            address = serverAddress;
            prefixLength = 24;
          }];
        };
        ipv6.addresses = [{
          address = "2001:db8:1::1";
          prefixLength = 64;
        }];
        useDHCP = false;
      };
    };
    firewall = {
      interfaces.${bindingDevice}.allowedUDPPorts = [
        # DHCP
        67
        68
        # TFTP
        69
      ];
      checkReversePath = false;
      enable = true;
      extraCommands = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ${sharedInternetDevice} -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -o ${sharedInternetDevice} -j MASQUERADE
      '';
      trustedInterfaces = [ bindingDevice ];
    };
  };
}
