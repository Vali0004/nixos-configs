{ config, lib, pkgs, modulesPath, ... }:

# Building:
# nix-build '<nixpkgs/nixos/release.nix>' --arg configuration ./vali.nix -A iso_minimal.x86_64-linux
# OR
# nix build .#packages.x86_64-linux.isoVali
let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    boot/boot.nix
    ./../modules/hosts.nix
    ./../modules/network-secrets.nix
    ./../modules/nix-settings.nix
    ./pkgs.nix
  ];

  environment.shellAliases = {
    l = null;
    ll = null;
    lss = "ls --color -lha";
  };

  networking = {
    hostName = "nixos-installer";
    hostId = "2632ac4c";
    networkmanager.enable = lib.mkForce false;
    useDHCP = true;
    wireless = {
      enable = true;
      networks = {
        "${config.secrets.wifi.ssid}" = {
          psk = config.secrets.wifi.password;
        };
      };
      userControlled.enable = true;
    };
    usePredictableInterfaceNames = false;
  };

  users.users = let
    my_keys = import ./../ssh_keys_personal.nix;
    common_keys = import ./../ssh_keys.nix;
  in {
    root.openssh.authorizedKeys.keys = my_keys ++ common_keys;
    vali = {
      extraGroups = [
        "wheel"
      ];
      isNormalUser = true;
      initialPassword = "hunter2";
      openssh.authorizedKeys.keys = my_keys ++ common_keys;
    };
  };

  system.stateVersion = "25.11";
}
