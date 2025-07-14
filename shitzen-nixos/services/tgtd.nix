{ config, inputs, lib, pkgs, ... }:

{
  services.tgtd = {
    enable = false;
  };
}