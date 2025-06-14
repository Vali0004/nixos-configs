{ config, lib, pkgs, ... }:

{
  services.monado = {
    defaultRuntime = true;
    enable = true;
  };
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
  };
}
