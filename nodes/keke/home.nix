args@{ sysconfig, config, pkgs # inputs.nixpkgs
, lib # inputs.nixpkgs.lib
, inputs, prelude, ... }:
let __findFile = prelude.__findFile; in {

  imports = [
    <modules/cab/home.nix>
    <modules/home-dumpster.nix>
  ];

}
