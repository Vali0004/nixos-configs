{
  services.localnetSSL = {
    enable = true;
    hosts = [
      "hass.localnet"
      "jellyfin.localnet"
      "kvm.localnet"
      "monitoring.localnet"
      "pihole.localnet"
      "zigbee2mqtt.localnet"
    ];
  };
}