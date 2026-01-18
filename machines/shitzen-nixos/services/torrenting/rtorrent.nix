{ config
, pkgs
, lib
, ... }:

let
  publicPeerPort = 3700;
  privatePeerPort = 3701;
  publicDhtPort = 6990;

  rtUser = config.services.rtorrent.user;
  rtGroup = config.services.rtorrent.group;

  publicBase = "/var/lib/rtorrent";
  privateBase = "/var/lib/rtorrent-private";

  privateSocket = "/run/rtorrent-private/rpc.sock";

  mkCfg = { base, downloadDir, peerPort, enableDht ? false, dhtPort ? null, privateMode ? false }: ''
    # Instance layout (base paths)
    method.insert = cfg.basedir, private|const|string, (cat,"${base}/")
    method.insert = cfg.watch,   private|const|string, (cat,(cfg.basedir),"watch/")
    method.insert = cfg.logs,    private|const|string, (cat,(cfg.basedir),"log/")
    method.insert = cfg.logfile, private|const|string, (cat,(cfg.logs),(system.time),".log")
    method.insert = cfg.rpcsock, private|const|string, (cat,"${if privateMode then privateSocket else config.services.rtorrent.rpcSocket}")

    # Create instance directories
    execute.throw = sh, -c, (cat, "mkdir -p ", (cfg.basedir), "/session ", (cfg.watch), " ", (cfg.logs))

    # Listening port for incoming peer traffic (fixed; you can also randomize it)
    network.port_range.set = ${toString peerPort}-${toString peerPort}
    network.port_random.set = no

    ${lib.optionalString enableDht ''
      # Tracker-less torrent and UDP tracker support
      dht.mode.set = auto
      dht.port.set = ${toString dhtPort}
      protocol.pex.set = yes
      trackers.use_udp.set = yes
      # Add bootstrap nodes for DHT
      schedule2 = dht_node_1, 15, 0, "dht.add_node=router.utorrent.com:6881"
      schedule2 = dht_node_2, 15, 0, "dht.add_node=dht.transmissionbt.com:6881"
      schedule2 = dht_node_3, 15, 0, "dht.add_node=router.bitcomet.com:6881"
      schedule2 = dht_node_4, 15, 0, "dht.add_node=dht.aelitis.com:6881"
    ''}

    ${lib.optionalString privateMode ''
      dht.mode.set = disable
      protocol.pex.set = no
      trackers.use_udp.set = no
    ''}

    # Peer settings
    throttle.max_uploads.set = 100

    throttle.min_peers.normal.set = 20
    throttle.max_peers.normal.set = 100
    throttle.min_peers.seed.set = -1
    throttle.max_peers.seed.set = -1
    trackers.numwant.set = 100

    # Verify hash on completion
    pieces.hash.on_completion.set = yes

    # Ratelimit to 15MiB/s on down, 8MiB/s on up
    throttle.global_down.max_rate.set_kb = 15360
    throttle.global_up.max_rate.set_kb = 8192

    # Encryption
    protocol.encryption.set = allow_incoming,try_outgoing,enable_retry

    pieces.preload.type.set = 2
    network.http.dns_cache_timeout.set = 25
    network.http.ssl_verify_host.set = 0
    network.http.ssl_verify_peer.set = 0

    # Limits for file handle resources, this is optimized for
    # an `ulimit` of 1024 (a common default). You MUST leave
    # a ceiling of handles reserved for rTorrent's internal needs!
    network.http.max_open.set = 32
    network.max_open_files.set = 600
    network.max_open_sockets.set = 300

    # Memory resource usage (increase if you have a large number of items loaded,
    # and/or the available resources to spend)
    pieces.memory.max.set = 3600M
    network.xmlrpc.size_limit.set = 8M

    # Basic operational settings (no need to change these)
    session.path.set = (cat, (cfg.basedir), "session/")
    directory.default.set = "${downloadDir}"
    log.execute = (cat, (cfg.logs), "execute.log")
    ##log.xmlrpc = (cat, (cfg.logs), "xmlrpc.log")
    execute.nothrow = sh, -c, (cat, "echo >", (session.path), "${if privateMode then "rtorrent-private.pid" else "rtorrent.pid"}", " ", (system.pid))

    # Other operational settings (check & adapt)
    encoding.add = utf8
    system.umask.set = 0027
    system.cwd.set = (cfg.basedir)
    network.http.dns_cache_timeout.set = 25
    schedule2 = monitor_diskspace, 15, 60, ((close_low_diskspace, 1000M))

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

    # Fixes flood
    method.redirect=load.throw,load.normal
    method.redirect=load.start_throw,load.start
  '';
in {
  networking.firewall.allowedTCPPorts = [
    publicPeerPort
    privatePeerPort
    6110
  ];

  networking.firewall.allowedUDPPorts = [
    publicPeerPort
    privatePeerPort
    publicDhtPort
  ];

  environment.systemPackages = [ pkgs.xmlrpc_c pkgs.socat ];

  services.rtorrent = {
    configText = lib.mkForce (mkCfg {
      base = publicBase;
      downloadDir = config.services.rtorrent.downloadDir;
      peerPort = publicPeerPort;
      enableDht = true;
      dhtPort = publicDhtPort;
      privateMode = false;
    });
    downloadDir = "/data/services/downloads";
    enable = true;
    port = publicPeerPort;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/rtorrent-private 07507755 ${config.services.rtorrent.user} ${config.services.rtorrent.group} - -"
    "d /var/lib/rtorrent-private/session 0775 ${config.services.rtorrent.user} ${config.services.rtorrent.group} - -"
    "d /var/lib/rtorrent-private/watch 0775 ${config.services.rtorrent.user} ${config.services.rtorrent.group} - -"
  ];

  # Cursed hack to allow for rtorrent-exporter to connect to the socket
  services.nginx = {
    enable = true;
    virtualHosts."rtorrent.localnet" = {
      enableACME = false;
      forceSSL = false;
      listen = [{ addr = "0.0.0.0"; port = 6110; }];
      locations."/RPC2".extraConfig = ''
        include ${config.services.nginx.package}/conf/scgi_params;
        scgi_pass unix:/run/rtorrent-private/rpc.sock;
      '';
    };
  };

  systemd.services.rtorrent.serviceConfig = {
    SystemCallFilter = "@system-service fchownat";
    RuntimeDirectoryMode = lib.mkForce 0775;
    LimitNOFILE = 524288;
  };

  systemd.services.rtorrent-private = {
    description = "rTorrent (private trackers)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = lib.mkNamespace {} // {
      Type = "simple";
      User = rtUser;
      Group = rtGroup;
      RuntimeDirectory = "rtorrent-private";
      RuntimeDirectoryMode = "0775";
      WorkingDirectory = privateBase;
      Environment = [
        "PATH=${lib.makeBinPath [ pkgs.rtorrent pkgs.bashInteractive pkgs.coreutils pkgs.findutils pkgs.gnugrep pkgs.gnused pkgs.systemd ]}"
      ];
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${privateBase}/session ${privateBase}/log";
      ExecStart = "${pkgs.rtorrent}/bin/rtorrent -n -o system.daemon.set=true -o import=${pkgs.writeText "rtorrent-private.rc" (mkCfg {
        base = privateBase;
        peerPort = privatePeerPort;
        downloadDir = "/data/services/downloads-private";
        enableDht = false;
        privateMode = true;
      })}";
      Restart = "on-failure";

      LimitNOFILE = 524288;
      SystemCallFilter = "@system-service fchownat";
    };
  };
}