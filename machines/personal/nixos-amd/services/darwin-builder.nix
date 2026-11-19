{ ... }:

# The Mac Pro 2013 (macOS, Nix 2.35) as an x86_64-darwin builder, while it is booted into macOS. Its nix-daemon is not
# on a non-interactive ssh PATH, so the store URL names it. vali is a trusted user there.
# nixpkgs 26.11 dropped x86_64-darwin, 26.05 still builds for it
{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "10.0.0.209?remote-program=/nix/var/nix/profiles/default/bin/nix-daemon";
      protocol = "ssh-ng";
      sshUser = "vali";
      sshKey = "/root/.ssh/macpro-builder";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUdaQUxyR2JGT2d0N21yWkpMZHpQMDVOYXdydnRJVHo3UWI2N1pOY2dtdGQ=";
      systems = [ "x86_64-darwin" ];
      maxJobs = 4;
      supportedFeatures = [ "big-parallel" ];
    }
  ];
  # builders fetch from the binary cache themselves instead of through this machine
  nix.settings.builders-use-substitutes = true;
}
