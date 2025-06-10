args@{ inputs, prelude, lib, config, pkgs, ... }:
with prelude; let __findFile = prelude.__findFile; in
{
  # Young streamer's kit (don't mistake with adolescent kit, that would be tiktok)
  programs.gphoto2 = on;
  users.users.cab.extraGroups = [ "camera" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="Funny Cam" exclusive_caps=1
  '';
}
