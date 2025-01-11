{ config, inputs, lib, pkgs, ... }:

{
  options = {
    vali.mc_prod = lib.mkOption {
      type = lib.types.bool;
    };
    vali.mc_test = lib.mkOption {
      type = lib.types.bool;
    };
  };
  config = lib.mkIf (config.vali.mc_prod || config.vali.mc_test) {
    services = {
      minecraft-servers = {
        dataDir = "/var/lib/minecraft";
        enable = true;
        eula = true;
        servers = {
          test = lib.mkIf config.vali.mc_test {
            autoStart = true;
            enable = true;
            files = import ./minecraft/test.nix { inherit pkgs; };
            whitelist = {
              FaintLove = "992e0e99-b817-4f58-96d9-96d4ec8c7d54";
              SOLOZ01 = "a02466ff-a71b-4540-8838-1b850cd4f659";
              kashikoi22 = "ab33a905-7f5f-4bfa-b0b3-852b8b0ac2e3";
            };
            jvmOpts = "-Xms4G -Xmx4G";
            package = pkgs.fabricServers.fabric-1_21_4;
            serverProperties = {
              admin-slot = true;
              allow-cheats = true;
              compression-algorithm = "zlib";
              compression-threshold = 2;
              difficulty = "hard";
              enable-command-block = true;
              enable-rcon = false;
              enforce-whitelist = true;
              entity-broadcast-range-percentage = 50;
              force-gamemode = false;
              gamemode = "survival";
              hardcore = false;
              max-players = 3;
              max-threads = 8;
              max-tick-time = 60000;
              motd = "Vali's Test Minecraft Server";
              query-port = 4300;
              server-name = "InertiaCraftTest";
              server-port = 4300;
              simulation-distance = 24;
              texturepack-required = true;
              tick-distance = 12;
              view-distance = 24;
              white-list = true;
            };
          };
          prod = lib.mkIf config.vali.mc_prod {
            autoStart = true;
            enable = true;
            files = import ./minecraft/prod.nix { inherit pkgs; };
            whitelist = {
              FaintLove = "992e0e99-b817-4f58-96d9-96d4ec8c7d54";
              Killer4563782 = "f159afef-984e-4343-bd7b-d94cfff96c63";
              SOLOZ01 = "a02466ff-a71b-4540-8838-1b850cd4f659";
              hophophop123 = "00000000-0000-0000-0009-01f4f5b93df8";
              kashikoi22 = "ab33a905-7f5f-4bfa-b0b3-852b8b0ac2e3";
            };
            jvmOpts = "-Xms13G -Xmx13G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
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
              query-port = 4301;
              server-ip = "0.0.0.0";
              server-name = "InertiaCraft";
              server-port = 4301;
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
      };
    };
  };
}