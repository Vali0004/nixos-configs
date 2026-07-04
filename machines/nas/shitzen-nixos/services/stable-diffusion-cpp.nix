{ config
, lib
, pkgs
, ... }:

{
  systemd.services.stable-diffusion-router = {
    enable = true;
    description = "stable-diffusion.cpp Router Service";
    serviceConfig = {
      Type = "simple";

      ExecStart = ''
        ${pkgs.stable-diffusion-cpp-rocm}/bin/sd-server \
          --listen-ip 0.0.0.0  \
          --listen-port 8090 \
          --backend diffusion=rocm0,vae=rocm0,te=cpu \
          --fa \
          -m /data/models/vision/juggernaut-xl-v9-Q8_0.gguf \
          --serve-html-path /data/models/web/index.html
      '';

      Restart = "always";
      RestartSec = "2s";

      User = "llm";
      Group = "llm";
    };

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
  };
}