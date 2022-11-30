args@{ inputs, lib, config, pkgs, ... }: with import "${inputs.self}/lib.nix" args; {

  programs.nix-ld.enable = true;
  environment.variables = {
     NIX_LD = pkgs.stdenv.cc.bintools.dynamicLinker;
  };

}
