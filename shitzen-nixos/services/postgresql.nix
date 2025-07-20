{ config, pkgs, lib, ... }:

{
  services.postgresql = {
    enable = true;
    settings.port = 5432;
  };
}