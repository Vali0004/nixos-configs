{ stdenv
,
}:

stdenv.mkDerivation {
  pname = "libida";
  version = "1.0";

  src = ./libida.tar.gz;

  unpackPhase = ''
    tar -xvzf $src
  '';

  installPhase = ''
    mkdir -p $out
    cp -r libida $out
    mv $out/libida $out/opt
  '';
}