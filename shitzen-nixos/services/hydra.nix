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
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = false;
    };
  };

  services.hydra = {
    buildMachinesFiles = [];
    enable = true;
    extraConfig = ''
      binary_cache_secret_key_file = /var/cache-priv-key.pem
      store-uri = file:///nix/store?secret-key=/var/cache-priv-key.pem
      max_output_size = ${toString (1024*1024*1024*3)} # 3gig
      max_concurrent_evals = 1
      evaluator_initial_heap_size = ${toString (1024*1024*1024)} # 1gig
      <github_authorization>
        Vali0004 = @${config.age.secrets.hydra-github-token.path}
        xenon-emu = @${config.age.secrets.hydra-github-token.path}
      </github_authorization>
      <githubstatus>
        jobs = xenon-emu:xenon.*
        inputs = xenon
        excludeBuildFromContext = 1
      </githubstatus>
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