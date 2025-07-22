{ config, inputs, lib, pkgs, ... }:

{
  services.jellyfin = {
    dataDir = "/data/services/jellyfin";
    enable = true;
    openFirewall = true;
    user = "vali";
  };
}