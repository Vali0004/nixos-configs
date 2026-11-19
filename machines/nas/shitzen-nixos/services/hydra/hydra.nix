{ config
, lib
, pkgs
, ... }:

{
  services.nginx.virtualHosts."hydra.lab004.dev" = {
    enableACME = true;
    forceSSL = true;

    # Ask robots not to scrape hydra, it has various expensive endpoints
    locations."=/robots.txt".alias = pkgs.writeText "hydra.lab004.dev-robots.txt" ''
      User-agent: *
      Disallow: /
      Allow: /$
    '';

    locations."/" = lib.mkProxy {
      ip = "$upstream";
      hasPort = false;
      config = ''
        limit_req zone=hydra-server burst=5;
      '';
    };

    locations."~ ^(/nix-cache-info$|/build/\\d+/download/|/.*\\.narinfo$|/nar/.*)" = lib.mkProxy {
      ip = "hydra-server";
      hasPort = false;
    };

    locations."/static/" = {
      alias = "${config.services.hydra.package}/libexec/hydra/root/static/";
    };
  };

  services.nginx.virtualHosts."hydra.kursu.dev" = {
    enableACME = true;
    forceSSL = true;

    # Ask robots not to scrape hydra, it has various expensive endpoints
    locations."=/robots.txt".alias = pkgs.writeText "hydra.kursu.dev-robots.txt" ''
      User-agent: *
      Disallow: /
      Allow: /$
    '';

    locations."/" = lib.mkProxy {
      ip = "$upstream";
      hasPort = false;
      config = ''
        limit_req zone=hydra-server burst=5;
      '';
    };

    locations."~ ^(/nix-cache-info$|/build/\\d+/download/|/.*\\.narinfo$|/nar/.*)" = lib.mkProxy {
      ip = "hydra-server";
      hasPort = false;
    };

    locations."/static/" = {
      alias = "${config.services.hydra.package}/libexec/hydra/root/static/";
    };
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

    locations."/" = lib.mkProxy {
      ip = "$upstream";
      hasPort = false;
      config = ''
        limit_req zone=hydra-server burst=5;
      '';
    };

    locations."~ ^(/nix-cache-info$|/build/\\d+/download/|/.*\\.narinfo$|/nar/.*)" = lib.mkProxy {
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
  '';

  services.hydra = {
    enable = true;
    # TODO: Make this a proper module
    extraConfig = ''
      binary_cache_secret_key_file = /var/hydra-lab004-cache-priv-key.pem
      store-uri = file:///nix/store?secret-key=/var/hydra-lab004-cache-priv-key.pem
      max_output_size = ${toString (1024*1024*1024*3)} # 3gig
      max_concurrent_evals = 1
      evaluator_initial_heap_size = ${toString (1024*1024*1024)} # 1gig
      <github_authorization>
        Vali0004 = TOKEN1
        xenon-emu = TOKEN1
      </github_authorization>
      <githubstatus>
        jobs = xenon-emu:xenon.*
        inputs = xenon
        excludeBuildFromContext = 1
      </githubstatus>
    '';
    hydraURL = "https://hydra.lab004.dev";
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

  # The queue runner no longer reads build machine files: builders run hydra-builder and connect to it over gRPC,
  # presenting a token from tokenPaths. It listens on the LAN for the desktop (nixos-amd), and this machine runs
  # its own agent too.
  services.hydra.queueRunner = {
    grpc.address = "0.0.0.0";
    settings.tokenPaths = [ "/var/lib/hydra/builder-token" ];
    # PureDarwin's kernel and libSystem builds log far more than the 64 MiB default
    settings.maxLogSize = 1024 * 1024 * 1024;
  };
  networking.firewall.interfaces.enp3s0.allowedTCPPorts = [ 50051 ];

  services.hydra-builder = {
    enable = true;
    queueRunnerAddr = "http://127.0.0.1:50051";
    authorizationFile = "/var/lib/hydra/builder-token";
    settings = {
      speedFactor = 1;
      maxJobs = 4;
      systems = [ "x86_64-linux" "i686-linux" ];
      supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
    };
  };
}