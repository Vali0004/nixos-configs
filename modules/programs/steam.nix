{ config
, lib
, pkgs
, ... }:

let
  dotnet = pkgs.buildEnv {
    name = "dotnet-spt";
    paths = [
      pkgs.dotnet-runtime_8
      pkgs.dotnet-runtime_10
      pkgs.dotnet-aspnetcore_10
    ];
    pathsToLink = [ "/share/dotnet" ];
    ignoreCollisions = true;
  };

  dotnetRoot = "${dotnet}/share/dotnet";
in {
  options.programs.steam = {
    enableGamescope = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to Gamescope or not.";
    };
    enableVramMgmt = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to dmemcg (VRAM Management) or not.";
    };
  };

  config = lib.mkIf config.programs.steam.enable {
    environment.sessionVariables = {
      DOTNET_ROOT = dotnetRoot;
      DOTNET_ROOT_X64 = dotnetRoot;
    };

    programs.steam = {
      extraCompatPackages = with pkgs; [
        #proton-ge-rtsp-bin - nixpkgs-xr
        proton-ge-bin
        protonplus
      ];
      gamescopeSession.enable = config.programs.steam.enableGamescope;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          dotnet
          webkitgtk_4_1
          libnotify
          gtk3
          glib
          gdk-pixbuf
          cairo
          pango
          atk
          libsoup_3
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

    systemd.services.dmemcg-booster = lib.mkIf config.programs.steam.enableVramMgmt {
      enable = true;
      after = [ "multi-user.target" ];
      description = "Service for enabling and controlling dmem cgroup limits for boosting foreground games, system-level";
      serviceConfig = {
        ExecStart = "${pkgs.dmemcg-booster}/bin/dmemcg-booster --use-system-bus";
      };
    };

    systemd.user.services.dmemcg-booster = lib.mkIf config.programs.steam.enableVramMgmt {
      enable = true;
      after = [ "multi-user.target" ];
      description = "Service for enabling and controlling dmem cgroup limits for boosting foreground games, user-level";
      serviceConfig = {
        ExecStart = "${pkgs.dmemcg-booster}/bin/dmemcg-booster";
      };
    };
  };
}