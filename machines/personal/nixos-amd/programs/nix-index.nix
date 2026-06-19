{ config
, lib
, pkgs
, ... }:

{
  programs.nix-index = {
    enable = true;
    enableZshIntegration = config.programs.zsh.enable;
    enableBashIntegration = config.programs.zsh.enable == false;
  };
}