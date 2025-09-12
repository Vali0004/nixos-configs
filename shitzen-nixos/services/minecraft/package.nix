{ config, inputs, lib, pkgs, ... }:

let
  modpack = pkgs.callPackage ./modpack {};

  mcPort = 4100;
  mcUdpPort = 4101;

  whitelist = {
    FaintLove     = "992e0e99-b817-4f58-96d9-96d4ec8c7d54";
    Killer4563782 = "f159afef-984e-4343-bd7b-d94cfff96c63";
    SOLOZ01       = "a02466ff-a71b-4540-8838-1b850cd4f659";
    kashikoi22    = "ab33a905-7f5f-4bfa-b0b3-852b8b0ac2e3";
    ICYPhoenix7   = "eb738909-f0a3-46ca-abdc-1d6669d97d34";
  };

  jvmOpts = lib.concatStringsSep " " [
    # JVM Heap Allocation
    "-Xms1G"
    "-Xmx6G"
    # Base JVM Options
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:+UnlockDiagnosticVMOptions"
    "-XX:+AlwaysActAsServerClassMachine"
    "-XX:+AlwaysPreTouch"
    "-XX:+DisableExplicitGC"
    "-XX:NmethodSweepActivity=1"
    "-XX:ReservedCodeCacheSize=400M"
    "-XX:NonNMethodCodeHeapSize=12M"
    "-XX:ProfiledCodeHeapSize=194M"
    "-XX:NonProfiledCodeHeapSize=194M"
    "-XX:-DontCompileHugeMethods"
    "-XX:MaxNodeLimit=240000"
    "-XX:NodeLimitFudgeFactor=8000"
    "-XX:+UseVectorCmov"
    "-XX:+PerfDisableSharedMem"
    "-XX:+UseFastUnorderedTimeStamps"
    "-XX:+UseCriticalJavaThreadPriority"
    "-XX:ThreadPriorityPolicy=1"
    # G1GC Options
    "-XX:+UseG1GC"
    "-XX:MaxGCPauseMillis=130"
    "-XX:G1NewSizePercent=28"
    "-XX:G1HeapRegionSize=16M"
    "-XX:G1ReservePercent=20"
    "-XX:G1MixedGCCountTarget=3"
    "-XX:InitiatingHeapOccupancyPercent=10"
    "-XX:G1MixedGCLiveThresholdPercent=90"
    "-XX:G1RSetUpdatingPauseTimePercent=0"
    "-XX:SurvivorRatio=32"
    "-XX:MaxTenuringThreshold=1"
    "-XX:G1SATBBufferEnqueueingThresholdPercent=30"
    "-XX:G1ConcMarkStepDurationMillis=5.0"
    "-XX:AllocatePrefetchStyle=3"
  ];
in {
  options.minecraft.prod = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the production Minecraft server.";
  };

  config = lib.mkMerge [
    {
      networking.firewall.allowedTCPPorts = [ mcPort ];
      networking.firewall.allowedUDPPorts = [ mcUdpPort ];

      services.minecraft-servers = {
        enable = true;
        dataDir = "/var/lib/minecraft";
        eula = true;

        managementSystem.systemd-socket.enable = true;
        managementSystem.tmux.enable = false;
      };

      nixpkgs.overlays = [
        (self: super: {
          jre_headless = pkgs.graalvmPackages.graalvm-ce;
        })
      ];

      services.nginx.virtualHosts."mc.fuckk.lol" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          extraConfig = "return 404;";
        };
      };
    }

    (lib.mkIf config.minecraft.prod {
      services.minecraft-servers.servers.prod = {
        enable = true;
        autoStart = true;

        files = {
          config = "${modpack}/config";
          defaultconfigs = "${modpack}/defaultconfigs";
          modernfix = "${modpack}/modernfix";
          mods = "${modpack}/mods";
        };

        inherit whitelist jvmOpts;
        package = pkgs.fabricServers.fabric-1_20_1;

        serverProperties = {
          admin-slot = true;
          allow-cheats = true;
          difficulty = "hard";
          enable-command-block = true;
          enforce-whitelist = true;
          entity-broadcast-range-percentage = 60;
          gamemode = "survival";
          max-tick-time = 60000;
          query-port = mcPort;
          server-ip = "0.0.0.0";
          server-name = "InertiaCraft";
          server-port = mcPort;
          simulation-distance = 6;
          sync-chunk-writes = false;
          texturepack-required = true;
          require-resource-pack = false;
          tick-distance = 8;
          use-alternate-keepalive = true;
          view-distance = 24;
          white-list = true;
        };
      };
    })
  ];
}
