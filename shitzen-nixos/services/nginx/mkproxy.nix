{ port ? 80, config ? "", webSockets ? false, https ? false }:

let
  protocol = if https then "https" else "http";
in {
  proxyPass = "${protocol}://127.0.0.1:${toString port}";
  proxyWebsockets = webSockets;
  extraConfig = ''
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto "https";
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    ${config}
  '';
}