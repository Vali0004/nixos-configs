{ pkgs, ... }:

{
  # Reaches the borrowed Mac mini (and the Pixel) for remote QEMU work.
  # First run after the rebuild: sudo tailscale up
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ 41641 ];

  environment.systemPackages = [ pkgs.tailscale ];
}
