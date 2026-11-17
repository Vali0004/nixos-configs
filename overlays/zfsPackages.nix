self: super: {
  zfs = (self.callPackage pkgs/zfs { configFile = "user"; }) {
    version = "2.4.2";
    rev = "af50420ac624caeae2cf157378ea6b5dcd394c46";
    hash = "sha256-Spta1VNwS+i9XwavdRoZZJWxEVYocAlDQCpffeZilPI=";
    kernelModuleAttribute = "zfs_unstable";
    kernelMinSupportedMajorMinor = "4.18";
    kernelMaxSupportedMajorMinor = "7.0";
    enableUnsupportedExperimentalKernel = true;
    tests = { };
  };
  zfs_2_4 = self.zfs;
  zfs_unstable = self.zfs;
  linuxPackages_6_18 = super.linuxPackages_6_18.extend (lpSelf: lpSuper: {
    zfs = (self.callPackage pkgs/zfs { configFile = "kernel"; inherit (lpSelf) kernel kernelModuleMakeFlags; }) {
      version = "2.4.2";
      rev = "af50420ac624caeae2cf157378ea6b5dcd394c46";
      hash = "sha256-Spta1VNwS+i9XwavdRoZZJWxEVYocAlDQCpffeZilPI=";
      kernelModuleAttribute = "zfs_unstable";
      kernelMinSupportedMajorMinor = "4.18";
      kernelMaxSupportedMajorMinor = "7.0";
      enableUnsupportedExperimentalKernel = true;
      tests = { };
    };
    zfs_2_4 = lpSelf.zfs;
    zfs_unstable = lpSelf.zfs;
  });
  linuxPackages_7_0 = super.linuxPackages_7_0.extend (lpSelf: lpSuper: {
    zfs = (self.callPackage pkgs/zfs { configFile = "kernel"; inherit (lpSelf) kernel kernelModuleMakeFlags; }) {
      version = "2.4.2";
      rev = "af50420ac624caeae2cf157378ea6b5dcd394c46";
      hash = "sha256-Spta1VNwS+i9XwavdRoZZJWxEVYocAlDQCpffeZilPI=";
      kernelModuleAttribute = "zfs_unstable";
      kernelMinSupportedMajorMinor = "4.18";
      kernelMaxSupportedMajorMinor = "7.0";
      enableUnsupportedExperimentalKernel = true;
      tests = { };
    };
    zfs_2_4 = lpSelf.zfs;
    zfs_unstable = lpSelf.zfs;
  });
}