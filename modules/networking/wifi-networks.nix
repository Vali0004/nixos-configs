{ lib, ... }:

let
  networkModule = {
    ssid = lib.mkOption {
      type = lib.types.str;
      description = "The Wi-Fi SSID used in `networking`.";
    };
    password = lib.mkOption {
      type = lib.types.str;
      description = "The Wi-Fi Password used in `networking`.";
    };
  };
in {

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
      description = "List of Wi-Fi networks (Name/SSID pairs). Name is used to match against network-secrests";
    };
  };

  config.wifi = lib.mkDefault {
    networks = [
      {
        name = "home";
        ssid = "Fera_mac";
      }
    ];
  };
}