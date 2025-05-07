{ config, lib, pkgs, port, ip ? "10.0.127.3", target ? "172.18.0.1" }:
{
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},bind=${ip},fork,reuseaddr TCP4:${target}:${toString port}";
    KillMode = "process";
    Restart = "always";
  };
}