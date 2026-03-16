{ pkgs
, ... }:

{
  environment.systemPackages = [ pkgs.mosquitto ];

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        users = {
          full_access = {
            password = "hunter2";
            acl = [
              "readwrite homeassistant/#"
              "readwrite zigbee2mqtt/#"
              "readwrite home/#"
              "readwrite $SYS/#"
            ];
          };
        };
        settings = {
          allow_anonymous = true;
        };
      }
    ];
    #logType = [ "all" ];
  };
}