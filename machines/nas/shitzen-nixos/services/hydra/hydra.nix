{ config
, lib
, pkgs
, ... }:

{
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

    locations."~ ^(/build/\\d+/download/|/.*\\.narinfo$|/nar/.*)" = lib.mkProxy {
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
    locations."=/robots.txt".alias = pkgs.writeText "hydra.fuckk.lolhydra.fuckk.lol-robots.txt" ''
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

    locations."~ ^(/build/\\d+/download/|/.*\\.narinfo$|/nar/.*)" = lib.mkProxy {
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

  services.hydra = {
    buildMachinesFiles = [];
    enable = true;
    # TODO: Make this a proper module
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
    hydraURL = "https://hydra.kursu.dev";
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