args@{ inputs, lib, config, pkgs, ... }:
with import "${inputs.self}/lib.nix" args;
{
  # Young streamer's kit (don't mistake with adolescent kit, that would be tiktok)
  programs.gphoto2 = on;
  users.users.cab.extraGroups = [ "camera" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
}
