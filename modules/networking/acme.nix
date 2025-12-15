{ config
, lib
, pkgs
, ... }:

{
  options.acme = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to ACME SSL Certificates.";
    };
    email = lib.mkOption {
      type = lib.types.str;
      default = "diorcheats.vali@gmail.com";
      description = "Email to use with ACME.";
    };
  };

  config = lib.mkIf config.acme.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = config.acme.email;
    };
  };
}