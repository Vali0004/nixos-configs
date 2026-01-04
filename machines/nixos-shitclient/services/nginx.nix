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
      locations."/" = {
        proxyPass = "http://shitzen-nixos:8096";
        proxyWebsockets = true;
      };
    };
    "kvm.localnet" = {
      forceSSL = false;
      locations."/" = {
        proxyPass = "http://10.0.0.7";
        proxyWebsockets = true;
      };
    };
    "monitoring.localnet" = {
      forceSSL = false;
      locations = {
        "/" = {
          return = "302 /grafana/";
        };
        "/prometheus/" = lib.mkProxy {
          ip = "shitzen-nixos";
          port = 3400;
        };
        "/grafana/" = {
          proxyPass = "http://10.0.0.6:3003";
          proxyWebsockets = true;
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