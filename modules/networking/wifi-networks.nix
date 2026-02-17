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
          bssid = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "The Wi-Fi BSID used in `networking.wireless`.";
          };
          open = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to use key_mgmt none.";
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
        ssid = "Fera_Mac";
      }
    ];
  };
}