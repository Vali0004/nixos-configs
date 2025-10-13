{ config, inputs, lib, pkgs, ... }:

{
  services.flaresolverr = {
    enable = true;
    openFirewall = true;
    port = 8191;
  };
}