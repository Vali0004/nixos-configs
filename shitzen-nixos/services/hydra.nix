{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ./nginx/mkproxy.nix;
in {
  nix = {
    buildMachines = [
      { hostName = "localhost";
        protocol = null;
        system = "x86_64-linux";
        supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
        maxJobs = 8;
      }
    ];
    extraOptions = ''
      allowed-uris = https://github.com/nixos github:
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "0:00:00";
      options = ''--max-freed "$((32 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';
    };
    settings.auto-optimise-store = true;
  };

  services.nginx.virtualHosts."hydra.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = mkProxy {
      port = 3001;
      webSockets = true;
    };
  };

  services.hydra = {
    buildMachinesFiles = [];
    enable = true;
    extraConfig = ''
      <git-input>
        timeout = 3600
      </git-input>
      enableUserAuth = 1
    '';
    hydraURL = "https://hydra.fuckk.lol";
    listenHost = "localhost";
    maxServers = 10;
    maxSpareServers = 2;
    minSpareServers = 1;
    minimumDiskFree = 2;
    minimumDiskFreeEvaluator = 1;
    notificationSender = "diorcheats.vali@gmail.com";
    port = 3001;
    useSubstitutes = true;
  };

  users.users.hydra-www.extraGroups = [ "hydra" ];
}