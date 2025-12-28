{ config
, pkgs
, ... }:

{
  networking.firewall.allowedTCPPorts = [
    # Home Assistant
    8123
  ];

  services.home-assistant = {
    enable = true;
    # Opt-out from declarative configuration management
    config = null;
    lovelaceConfig = null;
    configDir = "/var/lib/home-assistant";
    # Specify list of components required by your configuration
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "esphome"
      "google_translate"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
      "met"
      "radio_browser"
      "shopping_list"
      "wled"
    ];
    extraPackages = ps: with ps; [
      # Needed for Alexa
      aioamazondevices
      # Needed for PostgreSQL
      psycopg2
      # Needed for Camera
      av
      pyturbojpeg
      # Needed for Mobile App
      pynacl
      # Needed for DHCP
      aiodhcpwatcher
      aiodiscover
      # Needed for SSDP
      async-upnp-client
      # Needed for Go to RTC
      go2rtc-client
      # Needed for MQTT (Zigbee)
      paho-mqtt
    ];
  };
}