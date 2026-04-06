{ lib
, fetchurl
, rpmextract
, stdenv }:

let
  baseVersion = "16.1";
  subVersion = "7";
in stdenv.mkDerivation rec {
  pname = "shim";
  version = "${baseVersion}-${subVersion}";

  src = fetchurl {
    url = "https://kojipkgs.fedoraproject.org/packages/shim/${baseVersion}/${subVersion}/x86_64/shim-x64-${version}.x86_64.rpm";
    hash = "sha256-ChGfNIjl2ifKVcGGTujhMa+l7PJ2iThboJuAXrAN1gg=";
  };

  nativeBuildInputs = [
    rpmextract
  ];

  unpackPhase = ''
    rpmextract $src
  '';

  installPhase = ''
    mkdir -p $out/efi

    cp usr/lib/efi/shim/*/EFI/*/fbx64.efi $out/efi/
    cp usr/lib/efi/shim/*/EFI/*/mmx64.efi $out/efi/
    cp usr/lib/efi/shim/*/EFI/*/shim*.efi $out/efi/
  '';
}