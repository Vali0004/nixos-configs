self: super: {
  lib = super.lib // {
    mkNamespace = { name ? "netns" }: {
      NetworkNamespacePath = "/run/${name}/container";
      InaccessiblePaths = [
        "/run/nscd"
        "/run/resolvconf"
      ];
      BindReadOnlyPaths = [ "/etc/netns-resolv.conf:/etc/resolv.conf" ];
    };
  };
}