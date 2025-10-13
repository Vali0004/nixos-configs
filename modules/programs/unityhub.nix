{ config, lib, pkgs, ... }:

{
  options.programs.unityhub = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to Unity Hub.";
    };
  };

  config = lib.mkIf config.programs.unityhub.enable {
    environment.systemPackages = [ pkgs.unityhub ];

    xdg.mime.addedAssociations."x-scheme-handler/unityhub" = "unityhub.desktop";
  };
}
