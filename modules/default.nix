{ pkgs, lib, ... }:
with lib;
{
  require = [ ./env.nix ./core.nix ];

}
