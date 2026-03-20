{ config
, ... }:

{
  services.bindLocalnet = {
    enable = true;
    lanInterface = config.router.bridgeInterface;
    rpzCnames = [
      "ads.roku.com"
      "identity.ads.roku.com"
      "logs.roku.com"
      "austin.logs.roku.com"
      "cooper.logs.roku.com"
      "giga.logs.roku.com"
      "liberty.logs.roku.com"
      "scribe.logs.roku.com"
      "tyler.logs.roku.com"
      "cloudservices.roku.com"
      "customer-feedbacks.web.roku.com"
      "ravm.tv"
      "display.ravm.tv"
      "p.ravm.tv"
      "adsmeasurement.com"
      "roku.adsmeasurement.com"
      "securepubads.g.doubleclick.net"
      "lat-services.api.data.roku.com"
      "tpc.googlesyndication.com"
    ];
  };
}