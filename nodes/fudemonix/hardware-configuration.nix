{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  # Hardware config?
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  # boot.loader.raspberryPi = {
  #   enable = true;
  #   version = 3;
  #   uboot.enable = true;
  #   firmwareConfig = ''
  #     force_turbo=1
  #   '';
  # };
  

  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="00"
  '';

  boot.supportedFilesystems = lib.mkForce [ ];

}
