{ config, lib, pkgs, ... }:

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
      gamescopeSession.enable = config.programs.steam.enableGamescope;
      package = pkgs.steam.override {
        extraPkgs = pkgs: [
          pkgs.nss
          pkgs.nspr
        ];
      };
    };

    programs.gamemode.enable = config.programs.steam.enableGamescope;

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
      # Wine Tricks (proton)
      protontricks
    ];
  };
}
