{ config, inputs, lib, pkgs, ... }:

{
  services.nfs.server = {
    enable = true;
    exports = ''
      /data 10.0.0.201(rw,sync,no_subtree_check,no_root_squash) 10.0.0.202(rw,sync,no_subtree_check,no_root_squash) 10.0.0.190(rw,sync,no_subtree_check,no_root_squash)
    '';
  };
}