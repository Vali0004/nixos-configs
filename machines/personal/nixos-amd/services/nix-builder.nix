{ ... }:

# The desktop as a Hydra builder: an agent that connects to the queue runner on shitzen-nixos over gRPC and runs
# the builds it is given. It is much faster than the NAS, so the queue runner prefers it.
{
  services.hydra-builder = {
    enable = true;
    queueRunnerAddr = "http://10.0.0.4:50051";
    # the token the queue runner accepts, root:hydra 0640, the same as /var/lib/hydra/builder-token on the NAS
    authorizationFile = "/var/lib/hydra-builder/token";
    settings = {
      speedFactor = 4;
      maxJobs = 6;
      # the default 10% free is 130 GB on this 1.3 TB disk, which is nearly always in use: 1% is still 13 GB
      storeAvailThreshold = 1.0;
      buildDirAvailThreshold = 1.0;
      systems = [ "x86_64-linux" "i686-linux" ];
      supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
    };
  };
}
