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
      extraConfig = config;
    };
  };
}