{ config
, lib
, pkgs
, ... }:

let
  # pterodactyl server volume for the GTNH server
  serverDir = "/data/minecraft/gtnh";
  exporterPort = 9150;
  mapPort = 9151;
  mapDir = "/var/lib/minecraft-map";
  # texture-dump's atlas.png and blocks.json from a GTNH client (minecraft-mapper's tools/dump-textures.py),
  # copied here by hand, the textures belong to the mods so they stay out of the store
  textureDir = "/var/lib/minecraft-map-textures";

  # same sandbox for everything that reads the save
  hardening = {
    CapabilityBoundingSet = "";
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateTmp = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectSystem = "strict";
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    SystemCallArchitectures = "native";
  };
in {
  # the map is only served through nginx
  networking.firewall.allowedTCPPorts = [ exporterPort mapPort ];

  # the renderer and the web server share the tile db, so they need the same user
  users.users.minecraft-map = {
    isSystemUser = true;
    group = "minecraft-map";
  };
  users.groups.minecraft-map = { };

  # renders every pterodactyl backup into the tile history, timestamped with the backup time
  systemd.services.minecraft-map-render = {
    description = "Render GTNH backups into the map tile history";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = hardening // {
      ExecStart = "${pkgs.minecraft-mapper}/bin/biome-thingy -z ${serverDir}/backups -d ${mapDir}/tiles.db -j ${pkgs.minecraft-mapper}/share/biome-thingy -t ${textureDir} -c";
      # missing_colors.json and corrupt chunk dumps land in the working directory
      WorkingDirectory = mapDir;
      StateDirectory = "minecraft-map";
      User = "minecraft-map";
      Group = "minecraft-map";
      BindReadOnlyPaths = [ serverDir ];
      TemporaryFileSystem = "/data:ro";
      Restart = "always";
      RestartSec = 30;
      # a full render pins a core for several minutes, keep the server ahead of it
      Nice = 15;
      CPUSchedulingPolicy = "batch";
      IOSchedulingClass = "idle";
      RestrictAddressFamilies = [ "AF_UNIX" ];
    };
  };

  systemd.services.minecraft-map-web = {
    description = "GTNH map viewer and tile history";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = hardening // {
      ExecStart = "${pkgs.minecraft-mapper}/bin/tile-history -d ${mapDir}/tiles.db serve -l ${toString mapPort} -w ${pkgs.minecraft-mapper}/share/map-viewer -x ${textureDir}";
      StateDirectory = "minecraft-map";
      User = "minecraft-map";
      Group = "minecraft-map";
      Restart = "always";
      RestartSec = 10;
    };
  };

  systemd.services.minecraft-pollution-exporter = {
    description = "GTNH pollution, player and world metrics exporter";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = hardening // {
      # the save is mounted read only at the same path, parent dirs are 0700 so a bind is needed
      ExecStart = "${pkgs.minecraft-mapper}/bin/pollution-exporter -p ${serverDir}/World -l ${toString exporterPort}";
      BindReadOnlyPaths = [ serverDir ];
      DynamicUser = true;
      Restart = "always";
      RestartSec = 10;

      TemporaryFileSystem = "/data:ro";
    };
  };

  services.nginx.virtualHosts."map.play.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    # nginx sits in the wireguard namespace, the host is on the other end of veth0
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = mapPort;
      webSockets = false;
    };
  };

  services.prometheus.scrapeConfigs = [
    (lib.mkPrometheusJob {
      name = "minecraft-gtnh";
      port = exporterPort;
    })
  ];
}
