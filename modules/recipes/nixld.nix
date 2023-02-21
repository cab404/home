args@{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in {

  programs.nix-ld.enable = true;
  environment.variables = {
     # NIX_LD = lib.mkForce pkgs.stdenv.cc.bintools.dynamicLinker;
  };

}
