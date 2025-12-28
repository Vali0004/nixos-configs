self: super: {
  lib = super.lib // {
    mkProxy = { port ? 80
    , hasPort ? true
    , ip ? "127.0.0.1"
    , config ? ""
    , webSockets ? true
    , https ? false
    }: let
      protocol = if https then "https" else "http";
      portStr = if hasPort then ":${toString port}" else "";
    in {
      proxyPass = "${protocol}://${ip}${portStr}";
      proxyWebsockets = webSockets;
      extraConfig = ''
        # Generic proxy headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
      '' + config;
    };
  };
}