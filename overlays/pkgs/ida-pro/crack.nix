{ stdenv
,
}:

stdenv.mkDerivation {
  pname = "libida-crack";
  version = "1.0";

  # I uh, cannot provide this for obvious reasons.
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