{ config, inputs, lib, pkgs, ... }:

{
  services.jellyfin = {
    configDir = "/data/services/jellyfin/config";
    dataDir = "/data/services/jellyfin/data";
    logDir = "/data/services/jellyfin/log";
    enable = true;
    openFirewall = true;
    user = "vali";
  };
}