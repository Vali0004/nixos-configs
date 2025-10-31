{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ajax-xdp
    bpftools
  ];

  systemd.services.ajax-xdp = {
    serviceConfig.ExecStart = ''${pkgs.ajax-xdp}/bin/ajax-xdp -dev eth0 -webRoot "/xdp/" -webPort 9192 -listenIp 0.0.0.0 -rulesFile /var/lib/ajaxvpn/rules.json -saveRules -loadRules'';
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Restart = "always";
  };
}