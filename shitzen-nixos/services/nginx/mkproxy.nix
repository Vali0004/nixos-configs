{ port ? 80, config ? "", webSockets ? false }:
{
  proxyPass = "http://127.0.0.1:${toString port}";
  proxyWebsockets = webSockets;
  extraConfig = ''
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    ${config}
  '';
}