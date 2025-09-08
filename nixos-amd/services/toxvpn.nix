{ config, lib, pkgs, ... }:

let
  toxvpn = (builtins.getFlake "github:cleverca22/toxvpn/b4fe8242afe79b4e5c0fbc126f1379e0b574894b").packages.x86_64-linux.default;
in {
  systemd.services.toxvpn.serviceConfig.TimeoutStartSec = "infinity";
  services.toxvpn = {
    enable = true;
    auto_add_peers = [
      "e0f6bcec21be59c77cf338e3946a766cd17a8e9c40a2b7fe036e7996f3a59554b4ecafdc2df6" # chromeshit
      "3e24792c18ab55c59974a356e2195f165e0d967726533818e5ac0361b264ea671d1b3a8ec221" # shitzen
    ];
    localip = "10.0.127.4";
  };
}
