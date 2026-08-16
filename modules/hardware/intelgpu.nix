{ config
, lib
, pkgs
, ...
}:

{
  options.hardware.intel-gpu = {
    enable = lib.mkEnableOption "Intel GPU support";

    computeSupport = lib.mkEnableOption ''
      Intel GPU compute support through OpenCL and Level Zero
    '';

    mediaSupport = lib.mkEnableOption ''
      Intel GPU video acceleration through VA-API and oneVPL
    '';
  };

  config = lib.mkIf config.hardware.intel-gpu.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = lib.optionals config.hardware.intel-gpu.mediaSupport [
        pkgs.intel-media-driver
        pkgs.vpl-gpu-rt
      ] ++ lib.optionals config.hardware.intel-gpu.computeSupport [
        pkgs.intel-compute-runtime.drivers
        pkgs.level-zero
      ];

      extraPackages32 = lib.optionals config.hardware.intel-gpu.mediaSupport [
        pkgs.pkgsi686Linux.intel-media-driver
      ];
    };

    environment.sessionVariables = (lib.optionalAttrs config.hardware.intel-gpu.mediaSupport {
      LIBVA_DRIVER_NAME = "iHD";
    }) // (lib.optionalAttrs config.hardware.intel-gpu.computeSupport {
      ZE_ENABLE_ALT_DRIVERS = "${pkgs.intel-compute-runtime.drivers}/lib/libze_intel_gpu.so.1";

      LD_LIBRARY_PATH = lib.makeLibraryPath [
        pkgs.intel-compute-runtime.drivers
        pkgs.intel-graphics-compiler
      ];
    });

    environment.systemPackages = with pkgs; [
      # Vulkan / OpenGL inspection
      vulkan-tools
      mesa-demos

      # Intel GPU monitoring
      intel-gpu-tools
    ]
    ++ lib.optionals config.hardware.intel-gpu.mediaSupport [
      libva-utils
    ]
    ++ lib.optionals config.hardware.intel-gpu.computeSupport [
      clinfo
      level-zero
    ];
  };
}