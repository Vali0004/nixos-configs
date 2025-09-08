{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      toxvpn = (builtins.getFlake "github:cleverca22/toxvpn/403586be0181a0b20dfc0802580f7f919aaa83de").packages.x86_64-linux.default;
    })
  ];

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
