{ config, pkgs, lib, ... }:

{
  services.redis.servers = {
    "pterodactyl" = {
      enable = true;
      port = 6379;
    };
  };
}