{ config
, lib
, ... }:

{
  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    experimentalZstdSettings = true;
  };

  services.nginx.virtualHosts = {
    "hass.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "nixos-hass";
        port = 8123;
      };
    };
    "hass.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = lib.mkProxy {
        ip = "nixos-hass";
        port = 8123;
      };
    };
    "jellyfin.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "shitzen-nixos";
        port = 8096;
      };
    };
    "kvm.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "kvm-shitzen";
      };
    };
    "monitoring.localnet" = {
      forceSSL = false;
      locations = {
        "/" = {
          return = "302 /grafana/";
        };
        "/grafana/" = lib.mkProxy {
          ip = "shitzen-nixos";
          port = 3003;
        };
        "/prometheus/" = lib.mkProxy {
          ip = "shitzen-nixos";
          port = 3400;
        };
      };
    };
    "zigbee2mqtt.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "nixos-hass";
        port = 8099;
      };
    };
  };
}