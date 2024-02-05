args@{ sysconfig
, config
, pkgs # inputs.nixpkgs
, lib # inputs.nixpkgs.lib
, inputs
, prelude
, ...
}:
with prelude; let __findFile = prelude.__findFile; in
{
    virtualisation.podman = on;
}