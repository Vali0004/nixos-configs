{ config, ... }:

{
  security.pki.certificates = [
    (builtins.readFile ./cloudflare-ecc.pem)
    (builtins.readFile ./beammp.pem)
    (builtins.readFile ./localnet-rootCA.crt)
  ];
}