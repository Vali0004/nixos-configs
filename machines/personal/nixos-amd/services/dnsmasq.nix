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

  sharedInternetDevice = "eth0";
  bindingDevice = "enp18s0f4u2u1";

  serverAddress = "192.168.66.1";
  # the netboot installer and the iPXE binaries that chain into it, served over TFTP
  netboot = sys.config.system.build;
  tftpRoot = pkgs.linkFarm "nixos-netboot-tftp" [
    { name = "bzImage"; path = "${netboot.kernel}/bzImage"; }
    { name = "initrd"; path = "${netboot.netbootRamdisk}/initrd"; }
    { name = "netboot.ipxe"; path = "${netboot.netbootIpxeScript}/netboot.ipxe"; }
    { name = "ipxe.efi"; path = "${pkgs.ipxe}/ipxe.efi"; }
    { name = "undionly.kpxe"; path = "${pkgs.ipxe}/undionly.kpxe"; }
  ];
in {
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      # the USB NIC and its address can come later than dnsmasq, bind-dynamic waits for them
      bind-dynamic = true;

      interface = [ bindingDevice ];

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

      # firmware PXE gets iPXE (BIOS or UEFI), iPXE then loads the NixOS netboot script
      dhcp-match = [
        "set:ipxe,175"
        "set:efi64,option:client-arch,7"
        "set:efi64,option:client-arch,9"
      ];
      dhcp-boot = [
        "tag:ipxe,netboot.ipxe,,${serverAddress}"
        "tag:!ipxe,tag:efi64,ipxe.efi,,${serverAddress}"
        "tag:!ipxe,tag:!efi64,undionly.kpxe,,${serverAddress}"
      ];

      enable-tftp = true;
      tftp-root = "${tftpRoot}";

      log-dhcp = true;

      # Disable resolv.conf parsing, as we assign our own via DHCP.
      no-resolv = true;

      enable-ra = true;
      ra-param = [ "${bindingDevice},1800" ]; # M=1800, O=0

      port = 0; # Disable DNS fully
    };
  };

  # give the NIC its address whenever it appears, then (re)start dnsmasq on it
  systemd.services.dnsmasq = {
    after = [ "network-addresses-${bindingDevice}.service" ];
    wants = [ "network-addresses-${bindingDevice}.service" ];
  };

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
      # tailscale already sets loose, which also lets the NATed netboot clients through
      checkReversePath = "loose";
      enable = true;
      extraCommands = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ${sharedInternetDevice} -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -o ${sharedInternetDevice} -j MASQUERADE
      '';
      trustedInterfaces = [ bindingDevice ];
    };
  };
}
