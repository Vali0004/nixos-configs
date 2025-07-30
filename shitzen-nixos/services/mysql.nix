{ config, inputs, lib, pkgs, ... }:

{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
}