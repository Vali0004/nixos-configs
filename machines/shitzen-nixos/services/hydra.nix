{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ../modules/mkproxy.nix;
in {
  nix = {
    buildMachines = [
      { hostName = "shitzen-nixos";
        protocol = null;
        systems = [ "i686-linux" "x86_64-linux" ];
        supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
        maxJobs = 4;
      }
    ];
    extraOptions = ''
      allowed-uris = https://github.com https://api.github.com https://codeload.github.com https://raw.githubusercontent.com https://github.com/nixos github:
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

    # Ask robots not to scrape hydra, it has various expensive endpoints
    locations."=/robots.txt".alias = pkgs.writeText "hydra.fuckk.lol-robots.txt" ''
      User-agent: *
      Disallow: /
      Allow: /$
    '';

    locations."/" = mkProxy {
      ip = "$upstream";
      hasPort = false;
      config = ''
        limit_req zone=hydra-server burst=5;
      '';
    };

    locations."~ ^(/build/\\d+/download/|/.*\\.narinfo$|/nar/.*)" = mkProxy {
      ip = "hydra-server";
      hasPort = false;
    };

    locations."/static/" = {
      alias = "${config.services.hydra.package}/libexec/hydra/root/static/";
    };
  };

  systemd.services.hydra-init.preStart = lib.mkAfter ''
    originalConf=$(readlink -f /var/lib/hydra/hydra.conf)

    cp "$originalConf" /var/lib/hydra/hydra.conf.tmp

    token=$(tr -d '\n' < ${config.age.secrets.hydra-github-token.path})
    sed -i "s/TOKEN1/$token/g" /var/lib/hydra/hydra.conf.tmp

    token2=$(tr -d '\n' < ${config.age.secrets.hydra-runner-ajax-github-token.path})
    sed -i "s/TOKEN2/$token2/g" /var/lib/hydra/hydra.conf.tmp
  '';

  environment.etc."nix/netrc" = {
    user = "hydra";
    source = config.age.secrets.nix-netrc.path;
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
        Vali0004 = TOKEN1
        xenon-emu = TOKEN1
        AjaxVPN = TOKEN2
      </github_authorization>
      <githubstatus>
        jobs = xenon-emu:xenon.*
        inputs = xenon
        excludeBuildFromContext = 1
      </githubstatus>
      <githubstatus>
        jobs = AjaxVPN:AjaxVPN.*
        inputs = AjaxVPN
        excludeBuildFromContext = 1
      </githubstatus>
    '';
    hydraURL = "https://hydra.fuckk.lol";
    listenHost = "0.0.0.0";
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