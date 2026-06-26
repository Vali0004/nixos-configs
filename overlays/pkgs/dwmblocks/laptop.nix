{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  writeText,
}:

stdenv.mkDerivation {
  pname = "dwmblocks-laptop";
  version = "0-unstable-2025-06-07";

  src = fetchFromGitHub {
    owner = "nimaaskarian";
    repo = "dwmblocks-statuscmd-multithread";
    rev = "6700e322431b99ffc9a74b311610ecc0bc5b460a";
    hash = "sha256-TfPomjT/Z4Ypzl5P5VcVccmPaY8yosJmMLHrGBA6Ycg=";
  };

  buildInputs = [ libx11 ];

  postPatch = "cp ${./laptop.dwmblocks-config.h} blocks.def.h";

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Modular status bar for dwm written in c";
    homepage = "https://github.com/torrinfail/dwmblocks";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ sophrosyne ];
    platforms = lib.platforms.linux;
    mainProgram = "dwmblocks";
  };
}