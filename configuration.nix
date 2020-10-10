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

}
