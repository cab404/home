{ pkgs, lib, ... }:
with lib; {

  imports = [
    ./hw/dell-latitude-5400.nix
    ./modules/i3/system.nix
    ./modules/home-manager

    ./secret/system.nix
    ./secret/hardware-configuration.nix
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "yuna";

  _.user = "cab";
  _.desktop = "i3";

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?

}
