self: super: {
  lib = super.lib // {
    mkNamespace = { name ? "netns" }: {
      after = [ "wireguard-wg0.service" ];
      bindsTo = [ "wireguard-wg0.service" ];

      serviceConfig = {
        NetworkNamespacePath = "/run/${name}/container";
        InaccessiblePaths = [
          "/run/nscd"
          "/run/resolvconf"
        ];
        BindReadOnlyPaths = [
          "/etc/netns-resolv.conf:/etc/resolv.conf"
        ];
      };
    };
  };
}