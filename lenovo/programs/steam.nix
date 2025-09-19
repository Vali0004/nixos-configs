{ config, lib, pkgs, ... }:

{
  programs.steam = {
    package = pkgs.steam.override {
      extraPkgs = pkgs: [ pkgs.nss pkgs.nspr ];
    };
    dedicatedServer.openFirewall = true;
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };
  programs.gamemode.enable = true;
  environment.systemPackages = with pkgs; [
    lutris
    mangohud
    protonup-qt
    umu-launcher
  ];
}
