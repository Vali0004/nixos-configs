{ pkgs
, ... }:

{
  environment.systemPackages = with pkgs; [
    ajax-xdp
    bpftools
  ];

  systemd.services.ajax-xdp = {
    serviceConfig.ExecStart = "${pkgs.ajax-xdp}/bin/ajax-xdp -d eth0 -w '/xdp/' -p 9192 -i 0.0.0.0 -r /var/lib/ajaxvpn/rules.json -s -loadRules";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}