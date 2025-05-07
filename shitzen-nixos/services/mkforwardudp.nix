{ config, lib, pkgs, port, ip ? "10.0.127.3", target ? "172.18.0.1" }:
{
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    ExecStart = "${pkgs.socat}/bin/socat UDP-LISTEN:${toString port},bind=${ip},fork,reuseaddr UDP:${target}:${toString port}";
    KillMode = "process";
    Restart = "always";
  };
}