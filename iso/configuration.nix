{ config, lib, pkgs, modulesPath, ... }:

# Building:
# nix-build '<nixpkgs/nixos/release.nix>' --arg configuration ./vali.nix -A iso_minimal.x86_64-linux
# OR
# nix build .#packages.x86_64-linux.isoVali
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    boot/boot.nix
    ../modules/networking/hosts.nix
    ../modules/nix/settings.nix
    ../modules/environment/shell-aliases.nix
    ./pkgs.nix
  ];

  networking = {
    hostName = "nixos-installer";
    hostId = "2632ac4c";
    networkmanager = {
      wifi = {
        backend = "wpa_supplicant";
        powersave = false;
        scanRandMacAddress = true;
      };
      enable = true;
      insertNameservers = [
        "1.1.1.1"
      ];
      logLevel = "INFO";
    };
    usePredictableInterfaceNames = false;
  };

  users.users = {
    nixos.extraGroups = [
      "networkmanager"
    ];
    root.extraGroups = [
      "networkmanager"
    ];
  };

  system.stateVersion = "25.11";
}
