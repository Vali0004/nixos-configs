{ config, lib, pkgs, ... }:

let
  toxvpn = (builtins.getFlake "github:cleverca22/toxvpn/1830f9b8c12b4c5ef36b1f60f7e600cd1ecf4ccf").packages.x86_64-linux.default;
in {
  systemd.services.toxvpn.serviceConfig.TimeoutStartSec = "infinity";
  services.toxvpn = {
    enable = true;
    auto_add_peers = [
      "e0f6bcec21be59c77cf338e3946a766cd17a8e9c40a2b7fe036e7996f3a59554b4ecafdc2df6" # chromeshit
      "dd51f5f444b63c9c6d58ecf0637ce4c161fe776c86dc717b2e209bc686e56a5d2227dfee1338" # clever
      "a4ae9a2114f5310bef4381c463c09b9491c7f0cf0e962bc8083620e2555fd221020e75e411b4" # router
      "3e24792c18ab55c59974a356e2195f165e0d967726533818e5ac0361b264ea671d1b3a8ec221" # shitzen
    ];
    localip = "10.0.127.4";
  };
}