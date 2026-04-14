{ config
, lib
, pkgs
, ... }:

{
  options.programs.steam = {
    enableGamescope = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to Gamescope or not.";
    };
  };

  config = lib.mkIf config.programs.steam.enable {
    programs.steam = {
      extraCompatPackages = with pkgs; [
        #proton-ge-rtsp-bin - nixpkgs-xr
        proton-ge-bin
        protonplus
      ];
      gamescopeSession.enable = config.programs.steam.enableGamescope;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          nss
          nspr
        ];
      };
    };

    programs.gamemode.enable = config.programs.steam.enableGamescope;

    environment.systemPackages = with pkgs; [
      # Wine/Proton Manager/Wrapper
      lutris
      # Vk and OGL overlay for montioring FPS
      mangohud
      # Proton Plus
      protonplus
      # Proton GE GUI Manager
      protonup-qt
      # Steam CMD
      steamcmd
      # UMU Launcher
      umu-launcher
      # Wine Tricks (proton)
      protontricks
    ];

    systemd.services.dmemcg-booster = {
      enable = true;
      after = [ "multi-user.target" ];
      description = "Service for enabling and controlling dmem cgroup limits for boosting foreground games, system-level";
      serviceConfig = {
        ExecStart = "${pkgs.dmemcg-booster}/bin/dmemcg-booster --use-system-bus";
      };
    };

    systemd.user.services.dmemcg-booster = {
      enable = true;
      after = [ "multi-user.target" ];
      description = "Service for enabling and controlling dmem cgroup limits for boosting foreground games, user-level";
      serviceConfig = {
        ExecStart = "${pkgs.dmemcg-booster}/bin/dmemcg-booster";
      };
    };
  };
}
