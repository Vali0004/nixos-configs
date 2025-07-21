{ config, inputs, lib, pkgs, ... }:

let
  staticDir = pkgs.runCommand "static-site" { } ''
    mkdir -p $out
    cat > $out/index.html <<EOF
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=Edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>cache.fuckk.lol is up</title>
        <style>
          body {
            font-family: sans-serif;
            background-color: #111;
            color: #eee;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
          }
          .container {
            text-align: center;
            max-width: 600px;
            padding: 0 1em;
          }
          h1 {
            font-size: 2em;
            color: #33cc99;
          }
          p {
            font-size: 1.2em;
            color: #ccc;
            word-wrap: break-word;
            overflow-wrap: break-word;
          }
          a {
            color: #3399ff;
            text-decoration: underline;
            transition: color 0.3s ease;
          }
          a:hover, a:focus {
            color: #66b2ff;
            text-decoration: none;
            outline: none;
          }
          code {
            background: #222;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: monospace;
            color: #66f;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>cache.fuckk.lol is up</h1>
          <p><code>cache.fuckk.lol</code> is the <code>Nix</code> binary cache I host, providing <a href="https://github.com/xenon-emu/xenon">Xenon</a> builds, and whatever other projects I work on</p>
        </div>
      </body>
    </html>
    EOF
  '';
in {
  services.nginx.virtualHosts."cache.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."~ ^/(nix-cache|nar|log|.*\\.narinfo)$" = {
      proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
    };
    locations."^~ /" = {
      root = staticDir;
      index = "index.html";
    };
  };

  services.nix-serve = {
    enable = true;
    bindAddress = "127.0.0.1";
    port = 5000;
    secretKeyFile = "/var/cache-priv-key.pem";
  };
}