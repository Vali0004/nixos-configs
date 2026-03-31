{ pkgs
, ... }:

{
  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "hass"
    ];
    ensureUsers = [
      {
        name = "hass";
        ensureDBOwnership = true;
      }
    ];
    package = pkgs.postgresql_16;
    settings.port = 5432;
  };
}