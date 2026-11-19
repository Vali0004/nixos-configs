{ lib
, ... }:

{
  # unpatched http2 0day reported, force it off on every vhost, nixos defaults it on
  # https://is-a.cat/@ar/117634569518544368 - revert once a fixed nginx lands
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      config.http2 = lib.mkForce false;
    });
  };
}
