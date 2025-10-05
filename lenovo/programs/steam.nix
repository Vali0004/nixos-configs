{ config, lib, pkgs, ... }:

{
  programs.steam = {
    dedicatedServer.openFirewall = true;
    enable = true;
    gamescopeSession.enable = true;
    localNetworkGameTransfers.openFirewall = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [ nss nspr ];
    };
    remotePlay.openFirewall = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # Wine/Proton Manager/Wrapper
    lutris
    # Vk and OGL overlay for montioring FPS
    mangohud
    # Proton GE GUI Manager
    protonup-qt
    # Steam CMD
    steamcmd
    # UMU Launcher
    umu-launcher
  ];
}
