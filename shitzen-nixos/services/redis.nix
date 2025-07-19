{ config, pkgs, lib, ... }:

{
  services.redis.servers = {
    "pterodactyl" = {
      enable = true;
      port = 6379;
    };
    "convoy" = {
      enable = true;
      port = 6380;
    };
  };
}