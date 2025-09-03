{
  pkgs,
  lib,
  config,
  ...
}:
let
  baseUrl = "https://matrix.fuckk.lol";
  clientConfig."m.homeserver".base_url = baseUrl;
  serverConfig."m.server" = "matrix.fuckk.lol:443";
  mkWellKnown = data: ''
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in {
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "fuckk.lol" = {
        enableACME = true;
        forceSSL = true;
        locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
        locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
      };
      "matrix.fuckk.lol" = {
        enableACME = true;
        forceSSL = true;
        locations."/".extraConfig = ''
          return 404;
        '';
        locations."/_matrix".proxyPass = "http://[::1]:8008";
        locations."/_synapse/client".proxyPass = "http://[::1]:8008";
      };
    };
  };

  services.matrix-synapse = {
    enable = true;
    settings.server_name = "fuckk.lol";
    settings.public_baseurl = baseUrl;
    settings.registration_shared_secret_path = config.age.secrets.matrix.path;
    settings.listeners = [{
      port = 8008;
      bind_addresses = [ "::1" ];
      type = "http";
      tls = false;
      x_forwarded = true;
      resources = [{
        names = [
          "client"
          "federation"
        ];
        compress = true;
      }];
    }];
  };
}