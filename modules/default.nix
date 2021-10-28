{ pkgs, lib, ... }:
with lib;
{
  require = [ ./options.nix ./core.nix ];

}
