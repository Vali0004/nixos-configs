{ lib
, ... }:

{
  options = {
    wifi.networks = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "The Network name used to match against `config.networking.wireless.secretsFile`";
          };
          ssid = lib.mkOption {
            type = lib.types.str;
            description = "The Wi-Fi SSID used in `networking.wireless`.";
          };
        };
      });
      description = "List of Wi-Fi networks (Name/SSID pairs). Name is used to match against network-secrets";
    };
  };

  config.wifi = lib.mkDefault {
    networks = [
      {
        name = "home";
        ssid = "Fera_mac";
        bssid = "6a:7f:f0:19:82:72";
      }
    ];
  };
}