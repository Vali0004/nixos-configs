{ config, pkgs, ... }:

{
  environment.etc = {
    "dwmblocks/scripts/battery".source = pkgs.dwmblocks-battery;
    "dwmblocks/scripts/cpu".source = pkgs.dwmblocks-cpu;
    "dwmblocks/scripts/memory".source = pkgs.dwmblocks-memory;
    "dwmblocks/scripts/network".source = pkgs.dwmblocks-network;
    "dwmblocks/scripts/playerctl".source = pkgs.dwmblocks-playerctl;
  };
}