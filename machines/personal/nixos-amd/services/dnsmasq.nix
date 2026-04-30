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
in {
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      bind-interfaces = true;

      interface = [ "enp10s0" ];

      dhcp-authoritative = true;
      dhcp-range = [
        "192.168.100.2,192.168.100.254"
        "2001:db8:1::1000,2001:db8:1::2000,64,12h"
        "::,constructor:enp10s0,ra-stateless,ra-names,64,2h"
      ];

      dhcp-option = [
        "option:dns-server,1.1.1.1,8.8.8.8"
        "option6:dns-server,[2606:4700:4700::1111],[2001:4860:4860::8888]"
      ];

      # Disable resolv.conf parsing, as we assign our own via DHCP.
      no-resolv = true;

      enable-ra = true;
      ra-param = [ "enp10s0,1800" ]; # M=1800, O=0

      port = 0; # Disable DNS fully
    };
  };

  environment.systemPackages = [
    run-pixiecore
  ];

  networking = {
    interfaces = {
      enp10s0 = {
        ipv4 = {
          addresses = [{
            address = "192.168.100.1";
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
      allowedUDPPorts = [
        # DHCP
        67
        68
      ];
      checkReversePath = false;
      enable = true;
      extraCommands = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o wlp9s0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -o wlp9s0 -j MASQUERADE
      '';
      trustedInterfaces = [ "enp7s0f1" ];
    };
  };
}