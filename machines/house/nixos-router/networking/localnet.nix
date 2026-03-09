{
  services.localnetSSL = {
    enable = true;
    hosts = [
      "router.localnet"
      "hass.localnet"
      "jellyfin.localnet"
      "kvm.localnet"
      "monitoring.localnet"
      "pihole.localnet"
      "pihole-failover.localnet"
      "zigbee2mqtt.localnet"
    ];
  };
}