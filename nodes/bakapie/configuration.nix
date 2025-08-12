{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in
# %%MODULE_HEADER%%
{

  networking.hostName = "bakapie";
  _.user = "cab";
  boot.loader.timeout = 0;
  networking.networkmanager.enable = true;

  imports = [
    <modules/barecore.nix>
    <modules/podman.nix>
    <modules/recipes/tailscale.nix>
  ];



}
