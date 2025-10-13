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
  options.secrets = {
    wifi.networks = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          ssid = lib.mkOption {
            type = lib.types.str;
            description = "The Wi-Fi SSID used in `networking`.";
          };
          password = lib.mkOption {
            type = lib.types.str;
            description = "The Wi-Fi Password used in `networking`.";
          };
        };
      });
      description = "List of Wi-Fi networks (SSID/password pairs).";
    };
    zipline = {
      authorization = lib.mkOption {
        type = lib.types.str;
        description = "The Authorization string used in the `flameshot-upload` scrip.";
      };
    };
  };

  imports = [
    /home/vali/nixos-configs/modules/networking/secrets-private.nix
  ];

  config.secrets = lib.mkDefault {
    wifi = {
      networks = [
        {
          ssid = "DummySSID";
          password = "DummyPassword";
        }
      ];
    };
    zipline.authorization = "dummy";
  };
}