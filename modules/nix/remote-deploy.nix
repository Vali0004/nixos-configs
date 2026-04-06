{ config
, lib
, pkgs
, ... }:

let
  cfg = pkgs.writeText "configuration.nix" ''
    assert builtins.trace "Hey, wrong machine! Did you mean to run this in a different terminal?" false;
    {}
  '';
in {
  options.nixops-deploy = {
    enable = lib.mkEnableOption "Whether to enable NixOps deploy-based warnings.";
  };

  config = lib.mkIf config.nixops-deploy.enable {
    nix.nixPath = [
      "nixos-config=${cfg}"
      "nixpkgs=/run/current-system/nixpkgs"
    ];

    system.systemBuilderCommands = ''
      ln -sv ${pkgs.path} $out/nixpkgs
    '';
  };
}