{
  services.localnetSSL = {
    enable = true;
    hosts = [
      "router.localnet"
      "flood.localnet"
      "flood-private.localnet"
      "git.localnet"
      "hass.localnet"
      "jellyfin.localnet"
      "kvm.localnet"
      "lidarr.localnet"
      "manga.localnet"
      "monitoring.localnet"
      "prowlarr.localnet"
      "radarr.localnet"
      "readarr.localnet"
      "sonarr.localnet"
      "vaultwarden.localnet"
      "zigbee2mqtt.localnet"
    ];
  };
}