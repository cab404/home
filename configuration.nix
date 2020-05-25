{ pkgs, lib, ... }:
with lib;
{

  imports = [
    ./hardware-configuration.nix
    ./notebook.nix
  ];

  networking.hostName = "yuna";
  _.user = "cab";
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?

}
