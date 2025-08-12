{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in
# %%MODULE_HEADER%%
{
  imports = [
    <modules/core.nix>
    <modules/podman.nix>
  ];



}
