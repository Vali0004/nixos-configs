{ config, lib, pkgs, ... }:

{
  programs.steam = {
    dedicatedServer.openFirewall = true;
    enable = true;
    gamescopeSession.enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };
  programs.gamemode.enable = true;
  environment.systemPackages = with pkgs; [ mangohud protonup-qt lutris bottles heroic ];
}
