{ config, ... }:

{
  networking.extraHosts = ''
    10.0.0.31 lenovo
    10.0.0.124 chromeshit
    10.0.0.201 nixos-amd
    10.0.0.244 shitzen-nixos
    74.208.44.130 router-vps
  '';
}