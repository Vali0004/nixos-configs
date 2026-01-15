{ config
, lib
, pkgs
, ... }:

{
  options.hardware.wifi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Wi-Fi.";
    };
  };

  imports = [
    ../networking/wifi-networks.nix
  ];

  config.networking = lib.mkIf config.hardware.wifi.enable {
    # We use wpa_cli, no need for NM
    networkmanager.enable = lib.mkForce false;
    wireless = {
      enable = true;
      networks = lib.listToAttrs (map (network: {
        name = network.name;
        value = {
          ssid = network.ssid;
          bssid = if network.bssid != "" then network.bssid else null;
          pskRaw = "ext:psk_${network.name}";
        };
      }) config.wifi.networks);
      secretsFile = config.age.secrets.network-secrets.path;
      userControlled = true;
    };
  };
}