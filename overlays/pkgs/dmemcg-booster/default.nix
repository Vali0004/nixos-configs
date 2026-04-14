{ lib
, rustPlatform
, fetchzip
, dbus
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "dmemcg-booster";
  version = "0.1.0";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus.dev
  ];

  src = fetchzip {
    url = "https://gitlab.steamos.cloud/holo/dmemcg-booster/-/archive/0.1.2/dmemcg-booster-0.1.2.zip";
    hash = "sha256-qETBTccMJmB5IJPBK1sLTUdtpPfLFMKFwewLqpB/PgM=";
  };

  cargoHash = "sha256-dIWUQoHB2nFvHvaq3aDWItifFKHBsJ6EJjIbrM/prIw=";
}