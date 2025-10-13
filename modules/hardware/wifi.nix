{ config, lib, pkgs, ... }:

{
  options.hardware.wifi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Wi-Fi.";
    };
  };

  imports = [
    ../networking/secrets.nix
  ];

  config.networking = lib.mkIf config.hardware.wifi.enable {
    # We use wpa_cli, no need for NM
    networkmanager.enable = lib.mkForce false;
    wireless = {
      enable = true;
      networks = lib.listToAttrs (map (network: {
        name = network.ssid;
        value = { psk = network.password; };
      }) config.secrets.wifi.networks);
      userControlled.enable = true;
    };
  };
}