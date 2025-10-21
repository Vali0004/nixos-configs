{
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "10.0.0.0/24"
      "10.0.127.0/24"
    ];
    bantime = "24h";
    bantime-increment = {
      enable = true;
      formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      maxtime = "168h"; # 1 week
      overalljails = true;
    };
  };
}