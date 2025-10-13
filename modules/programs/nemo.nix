{ config, lib, pkgs, ... }:

{
  options.programs.nemo = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to Nemo (Qt File Manager).";
    };
  };

  config = lib.mkIf config.programs.nemo.enable {
    xdg.mime.defaultApplications."inode/directory" = "nemo.desktop";

    environment.systemPackages = [ pkgs.nemo-with-extensions ];
  };
}
