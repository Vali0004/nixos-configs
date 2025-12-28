{ config
, ... }:

{
  networking.firewall.allowedTCPPorts = [
    config.services.zigbee2mqtt.settings.frontend.port
  ];

  services.zigbee2mqtt = {
    enable = true;

    settings = {
      advanced = {
        channel = 25;
      };

      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://127.0.0.1:1883";
        user = "full_access";
        password = "hunter2";
      };

      serial = {
        adapter = "zstack";
        baudrate = 115200;
        port = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
      };

      frontend.port = 8099;
    };
  };

  users.users.zigbee2mqtt.extraGroups = [ "plugdev" ];
}