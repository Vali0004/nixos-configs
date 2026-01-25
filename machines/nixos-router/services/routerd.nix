{ pkgs
, ... }:

{
  networking.firewall.allowedTCPPorts = [
    4390
  ];

  systemd.services.routerd = {
    description = "Router metrics + net admin daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "pihole-ftl.service" ];
    requires = [ "network-online.target" "pihole-ftl.service" ];

    path = with pkgs; [
      iproute2
      systemd
      coreutils
      gnugrep
      gawk
      procps
      conntrack-tools
    ];

    serviceConfig = {
      ExecStart = "${pkgs.nodejs_24}/bin/node ${pkgs.routerd}/lib/node_modules/routerd/server.js";
      Restart = "always";
      RestartSec = 2;

      Environment = [
        "PORT=4390"
        "POLL_SECONDS=2"
        "CMD_TIMEOUT_MS=1500"
        "DNSMASQ_LEASES=/var/lib/misc/dnsmasq.leases"
        "DNSMASQ_UNIT=pihole-ftl.service"
        "ALLOWED_UNITS=pihole-ftl.service"
        "SECRET=dummy"
      ];

      User = "root";
      Group = "root";

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = false;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = false;
      SystemCallArchitectures = "native";
    };
  };
}