{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ ajax-xdp bpftools ];
  #systemd.services.ajax-xdp = {
  #  serviceConfig.ExecStart = "${pkgs.ajax-xdp}/bin/ajax-xdp -dev eth0";
  #  after = [ "network.target" ];
  #  wantedBy = [ "multi-user.target" ];
  #  serviceConfig.Restart = "always";
  #};
}
