{ config
, lib
, pkgs
, ... }:

{
  options.acme = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to Gtk support.";
    };
  };

  config = lib.mkIf config.acme.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = "diorcheats.vali@gmail.com";
    };
  };
}