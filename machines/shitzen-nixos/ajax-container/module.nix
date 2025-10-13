{ config, pkgs, lib, ... }:

{
  networking = {
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "eth0";
      enableIPv6 = true;
    };
  };

  containers.ajax = {
    autoStart = true;
    forwardPorts = [
      {
        containerPort = 3000;
        hostPort = 3200;
        protocol = "tcp";
      }
      {
        containerPort = 3001;
        hostPort = 3201;
        protocol = "tcp";
      }
      {
        containerPort = 8080;
        hostPort = 8080;
        protocol = "tcp";
      }
    ];
    hostAddress = "10.0.0.244";
    hostAddress6 = "fc00::1";
    localAddress = "10.0.0.245";
    localAddress6 = "fc00::2";
    privateNetwork = true;
    config = { config, pkgs, lib, ... }: {
      imports = [
        services/grafana/module.nix
        services/prometheus.nix
        ./hosts.nix
      ];

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [
            config.services.grafana.settings.server.http_port # Grafana
            config.services.prometheus.port # Prometheus
          ];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = "diorcheats.vali@gmail.com";
      };

      services = {
        openssh = {
          enable = true;
          settings.PasswordAuthentication = false;
        };
        resolved.enable = true;
      };

      system.stateVersion = "25.11";

      time.timeZone = "America/Detroit";
    };
  };
}