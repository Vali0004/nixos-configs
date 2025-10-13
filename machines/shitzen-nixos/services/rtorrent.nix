{ config, pkgs, lib, ... }:

let
  dht-port = 6990;
  peer-port = 3700;
  web-port = 3701;
  mkProxy = import ../modules/mkproxy.nix;
in {
  networking.firewall.allowedUDPPorts = [ dht-port ];

  services.rtorrent = {
    configText = lib.mkForce ''
      # Instance layout (base paths)
      method.insert = cfg.basedir, private|const|string, (cat,"${config.services.rtorrent.dataDir}/")
      method.insert = cfg.watch,   private|const|string, (cat,(cfg.basedir),"watch/")
      method.insert = cfg.logs,    private|const|string, (cat,(cfg.basedir),"log/")
      method.insert = cfg.logfile, private|const|string, (cat,(cfg.logs),(system.time),".log")
      method.insert = cfg.rpcsock, private|const|string, (cat,"${config.services.rtorrent.rpcSocket}")

      # Create instance directories
      execute.throw = sh, -c, (cat, "mkdir -p ", (cfg.basedir), "/session ", (cfg.watch), " ", (cfg.logs))

      # Listening port for incoming peer traffic (fixed; you can also randomize it)
      network.port_range.set = ${toString config.services.rtorrent.port}-${toString config.services.rtorrent.port}
      network.port_random.set = no

      # Tracker-less torrent and UDP tracker support
      dht.mode.set = auto
      dht.port.set = ${toString dht-port}
      protocol.pex.set = yes
      trackers.use_udp.set = yes

      # Add bootstrap nodes for DHT
      schedule2 = dht_node_1, 15, 0, "dht.add_node=dht.libtorrent.org:25401"
      schedule2 = dht_node_2, 15, 0, "dht.add_node=dht.transmissionbt.com:6881"

      # Peer settings
      throttle.max_uploads.set = 100
      throttle.max_uploads.global.set = 250

      throttle.min_peers.normal.set = 20
      throttle.max_peers.normal.set = 60
      throttle.min_peers.seed.set = -1
      throttle.max_peers.seed.set = -1
      trackers.numwant.set = 60

      # Verify hash on completion
      pieces.hash.on_completion.set = yes

      # Ratelimit to 10MiB/s on down, 1MiB/s on up
      throttle.global_down.max_rate.set_kb = 10240
      throttle.global_up.max_rate.set_kb = 1024

      protocol.encryption.set = allow_incoming,try_outgoing,enable_retry

      # Limits for file handle resources, this is optimized for
      # an `ulimit` of 1024 (a common default). You MUST leave
      # a ceiling of handles reserved for rTorrent's internal needs!
      network.http.max_open.set = 50
      network.max_open_files.set = 600
      network.max_open_sockets.set = 3000

      # Memory resource usage (increase if you have a large number of items loaded,
      # and/or the available resources to spend)
      pieces.memory.max.set = 1800M
      network.xmlrpc.size_limit.set = 4M

      # Basic operational settings (no need to change these)
      session.path.set = (cat, (cfg.basedir), "session/")
      directory.default.set = "${config.services.rtorrent.downloadDir}"
      log.execute = (cat, (cfg.logs), "execute.log")
      ##log.xmlrpc = (cat, (cfg.logs), "xmlrpc.log")
      execute.nothrow = sh, -c, (cat, "echo >", (session.path), "rtorrent.pid", " ", (system.pid))

      # Other operational settings (check & adapt)
      encoding.add = utf8
      system.umask.set = 0027
      system.cwd.set = (cfg.basedir)
      network.http.dns_cache_timeout.set = 25
      schedule2 = monitor_diskspace, 15, 60, ((close_low_diskspace, 1000M))

      # Watch directories (add more as you like, but use unique schedule names)
      #schedule2 = watch_start, 10, 10, ((load.start, (cat, (cfg.watch), "start/*.torrent")))
      #schedule2 = watch_load, 11, 10, ((load.normal, (cat, (cfg.watch), "load/*.torrent")))

      # Logging:
      #   Levels = critical error warn notice info debug
      #   Groups = connection_* dht_* peer_* rpc_* storage_* thread_* tracker_* torrent_*
      print = (cat, "Logging to ", (cfg.logfile))
      log.open_file = "log", (cfg.logfile)
      ## Basic logging
      log.add_output = "info", "log"
      log.add_output = "error", "log"
      log.add_output = "dht_router", "log"
      #log.add_output = "debug", "log"
      #log.add_output = "dht_debug", "log"
      #log.add_output = "peer_debug", "log"
      #log.add_output = "tracker_debug", "log"

      # XMLRPC
      scgi_local = (cfg.rpcsock)
      schedule = scgi_group,0,0,"execute.nothrow=chown,\":${config.services.rtorrent.group}\",(cfg.rpcsock)"
      schedule = scgi_permission,0,0,"execute.nothrow=chmod,\"g+w,o=\",(cfg.rpcsock)"

      # Encryption
      encryption = allow_incoming,enable_retry,prefer_plaintext

      # Fixes flood
      method.redirect=load.throw,load.normal
      method.redirect=load.start_throw,load.start
      method.insert=d.down.sequential,value|const,0
      method.insert=d.down.sequential.set,value|const,0
    '';
    downloadDir = "/data/services/downloads";
    enable = true;
    port = peer-port;
    openFirewall = true;
  };

  services.flood = {
    enable = true;
    host = "0.0.0.0";
    port = web-port;
    openFirewall = true;
    extraArgs = [
      "--rtsocket=${config.services.rtorrent.rpcSocket}"
    ];
  };

  services.nginx.virtualHosts."flood.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = mkProxy {
      port = web-port;
    };
  };

  systemd.services.flood.serviceConfig = {
    Environment = "HOME=/var/lib/flood";
    Group = "rtorrent";
    ReadWritePaths = [
      "/var/lib/flood"
      "/data/private/Media"
      "/data/services/downloads"
    ];
    SupplementaryGroups = [
      config.services.rtorrent.group
    ];
    User = "rtorrent";
  };
  systemd.services.rtorrent.serviceConfig.SystemCallFilter = "@system-service fchownat";
}