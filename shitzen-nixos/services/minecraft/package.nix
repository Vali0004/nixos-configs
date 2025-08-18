{ config, inputs, lib, pkgs, ... }:

{
  options.minecraft.prod = lib.mkOption {
    type = lib.types.bool;
  };

  config.networking.firewall.allowedTCPPorts = [
    4100
  ];

  config.services.minecraft-servers = {
    dataDir = "/var/lib/minecraft";
    enable = true;
    eula = true;

    managementSystem.systemd-socket.enable = true;
    managementSystem.tmux.enable = false;

    servers.prod = lib.mkIf config.minecraft.prod {
      autoStart = true;
      enable = true;
      files = import ./prod.nix { fetchurl = pkgs.fetchurl; writeText = pkgs.writeText; };

      whitelist = {
        FaintLove = "992e0e99-b817-4f58-96d9-96d4ec8c7d54";
        Killer4563782 = "f159afef-984e-4343-bd7b-d94cfff96c63";
        SOLOZ01 = "a02466ff-a71b-4540-8838-1b850cd4f659";
        kashikoi22 = "ab33a905-7f5f-4bfa-b0b3-852b8b0ac2e3";
        ICYPhoenix7 = "eb738909-f0a3-46ca-abdc-1d6669d97d34";
      };

      jvmOpts = "-Xms4G -Xmx4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
      package = pkgs.fabricServers.fabric-1_21_4;

      serverProperties = {
        admin-slot = true;
        allow-cheats = true;
        compression-algorithm = "snappy";
        compression-threshold = 0;
        difficulty = "hard";
        enable-command-block = true;
        enable-rcon = false;
        enforce-whitelist = true;
        entity-broadcast-range-percentage = 40;
        force-gamemode = false;
        gamemode = "survival";
        hardcore = false;
        max-threads = 0;
        max-tick-time = 60000;
        network-compression-threshold = 512;
        query-port = 4100;
        server-ip = "0.0.0.0";
        server-name = "InertiaCraft";
        server-port = 4100;
        simulation-distance = 4;
        sync-chunk-writes = false;
        texturepack-required = true;
        require-resource-pack = true;
        resource-pack = "https://fuckk.lol/minecraft/resource-pack.zip";
        tick-distance = 12;
        use-alternate-keepalive = true;
        view-distance = 32;
        white-list = true;
      };
    };
  };
}
