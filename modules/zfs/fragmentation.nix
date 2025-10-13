{ config, lib, pkgs, ... }:

{
  options.zfs.fragmentation = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable zfs fragmentation Prometheus exporter.";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for port 9103.";
    };
  };

  config = lib.mkIf config.zfs.fragmentation.enable {
    networking.firewall.allowedTCPPorts = lib.optionals config.zfs.fragmentation.openFirewall [ 9103 ];

    systemd.services.zfs-fragmentation = {
      serviceConfig.ExecStart = "${pkgs.zfs-fragmentation}/bin/zfs-fragmentation";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Restart = "always";
    };
  };
}