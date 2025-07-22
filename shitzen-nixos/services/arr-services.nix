{ config, inputs, lib, pkgs, ... }:

{
  services.prowlarr = {
    dataDir = "/data/services/prowlarr/data";
    enable = true;
    openFirewall = true;
  };

  services.sonarr = {
    dataDir = "/data/services/sonarr/data";
    enable = true;
    group = "users";
    openFirewall = true;
    user = "vali";
  };

  services.radarr = {
    dataDir = "/data/services/radarr/data";
    enable = true;
    group = "users";
    openFirewall = true;
    user = "vali";
  };
}