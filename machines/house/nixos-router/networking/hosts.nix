{ config
, ... }:

{
  networking.extraHosts = ''
    10.0.0.2 home-assistant.localnet home-assistant
    10.0.0.4 shitzen.localnet shitzen-nixos
    10.0.0.5 shitzen-kvm.localnet shitzen-nixos-kvm
    10.0.0.1 router.localnet ${config.networking.hostName}
    10.0.0.1 hass.localnet ${config.networking.hostName}
    10.0.0.1 jellyfin.localnet ${config.networking.hostName}
    10.0.0.1 kvm.localnet ${config.networking.hostName}
    10.0.0.1 monitoring.localnet ${config.networking.hostName}
    10.0.0.1 rtorrent.localnet ${config.networking.hostName}
    10.0.0.1 pihole.localnet ${config.networking.hostName}
    10.0.0.1 pihole-failover.localnet ${config.networking.hostName}
    10.0.0.1 proxmox.localnet ${config.networking.hostName}
    10.0.0.1 zigbee2mqtt.localnet ${config.networking.hostName}
  '';
}