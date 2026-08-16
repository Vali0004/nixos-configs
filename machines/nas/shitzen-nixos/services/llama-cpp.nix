{ config
, lib
, pkgs
, ... }:

let
  llama-cpp = pkgs.llama-cpp.override { syclSupport = true; vulkanSupport = true; };
in {
  systemd.services.llama-router = {
    enable = true;
    description = "llama.cpp Router Service";
    path = with pkgs; [
      bashNonInteractive
      coreutils
      findutils
      git
      gnugrep
      gnused
      procps
      (python3.withPackages (ps: with ps; [ numpy ]))
      util-linux
      which
    ];
    environment = {
      ZE_ENABLE_ALT_DRIVERS = "${pkgs.intel-compute-runtime.drivers}/lib/libze_intel_gpu.so.1";
      LD_LIBRARY_PATH = lib.makeLibraryPath [
        pkgs.intel-compute-runtime.drivers
        pkgs.intel-graphics-compiler
      ];
      ONEAPI_DEVICE_SELECTOR = "level_zero:gpu";
      ZES_ENABLE_SYSMAN = "1";
      GGML_BACKEND_DEVICE = "SYCL0";
    };
    serviceConfig = {
      Type = "simple";

      ExecStart = ''
        ${llama-cpp}/bin/llama-server \
          --host 0.0.0.0 \
          --models-preset /data/ai/models/presets.ini \
          --ui-mcp-proxy \
          --tools all \
          --api-key-file ${config.age.secrets.llama-cpp-key.path}
      '';

      Restart = "always";
      RestartSec = "2s";

      User = "llm";
      Group = "llm";

      # Don't give new privs
      NoNewPrivileges = true;
      # Private /tmp
      PrivateTmp = true;

      # No SUID/SGID
      RestrictSUIDSGID = true;

      # Don't lock down /proc too much
      ProtectProc = "default";
      ProcSubset = "all";

      # No kernel modules (goodbye copy fail)
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      LockPersonality = true;

      # Make the service's own filesystem mostly immutable
      ProtectSystem = "strict";
      ProtectHome = "read-only";

      # It needs to see users
      PrivateUsers = false;

      # Mostly closed GPU (private devices needs to be off for Vulkan/ROCm)
      PrivateDevices = false;

      DevicePolicy = "closed";
      DeviceAllow = [
        "char-drm rw"
      ];

      BindReadOnlyPaths = [
        "/run/opengl-driver"
        "/run/opengl-driver-32"
        "/sys/class/drm"
        "/sys/devices"
      ];

      ReadOnlyPaths = [
        "/data/ai/models"
        "/proc"
        "/sys"
        "/etc/os-release"
        "/etc/machine-id"
      ];

      ReadWritePaths = [
        config.users.users.llm.home
      ];

      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];

      PrivateNetwork = false;

      IPAddressAllow = [ "127.0.0.0/8" "::1/128" "192.168.100.0/24" ];
      IPAddressDeny = "any";

      InaccessiblePaths = [
        # Block /nix/var
        "/nix/var"
        # Block /run/current-system/sw and sw/bin
        "/run/current-system/sw"

        # Block core system paths
        "/etc"
        "/kernels"
        "/boot"
        "/lib"
        "/lib64"
        "/mnt"
        "/opt"
        "/root"
        "/usr"
        "/var"

        # Block block devices
        "/dev/block"
        "/dev/sda"
        "/dev/sdb"
        "/dev/sdc"
        "/dev/sdd"
        "/dev/sde"
        "/dev/zfs"
        "/dev/mapper"
        "/dev/disk"

        # Block generic devices
        "/dev/bsg"
        "/dev/bus"
        "/dev/console"
        "/dev/core"
        "/dev/input"
        "/dev/snd"
        "/dev/net"
        "/dev/fd"

        # Block memory
        "/dev/mem"

        # Block shm
        "/dev/shm"

        # Block RTC
        "/dev/rtc"
        "/dev/rtc0"

        # Block TTY
        "/dev/tty"
        "/dev/tty0"
        "/dev/tty1"
        "/dev/ttyS0"
        "/dev/ttyS1"
        "/dev/ttyS2"
        "/dev/ttyS3"

        # Block vhost
        "/dev/vhost-net"
        "/dev/vhost-vsock"

        # Block other devices
        "/dev/pts"
        "/dev/cpu_dma_latency"
        "/dev/ptmx"
      ];

      # No syscalls (mostly)
      SystemCallArchitectures = "native";
      SystemCallFilter = "@system-service";
    };

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
  };

  services.nginx.virtualHosts."llm.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = lib.mkProxy {
        https = false;
        ip = "192.168.100.1";
        port = 8080;
        webSockets = true;
      };
      "/dashboard".return = "301 /";
    };
  };

  users = {
    users.llm = {
      isSystemUser = true;
      group = "llm";
      home = "/home/llm";
      createHome = true;
      extraGroups = [
        "render"
        "video"
      ];
    };
    groups.llm = {};
  };
}