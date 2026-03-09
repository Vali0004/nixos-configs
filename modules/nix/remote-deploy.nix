{ config, lib, pkgs, ... }:

let
  cfg = pkgs.writeText "configuration.nix" ''
    assert builtins.trace "Hey, wrong machine! Did you mean to run this in a different terminal?" false;
    {}
  '';
in {
  options.nixops-deploy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable NixOps deplpoy-based warnings.";
    };
  };

  config = lib.mkIf config.nixops-deploy.enable {
    nix.nixPath = [
      "nixos-config=${cfg}"
      "nixpkgs=/run/current-system/nixpkgs"
    ];

    system.extraSystemBuilderCmds = ''
      ln -sv ${pkgs.path} $out/nixpkgs
    '';
  };
}