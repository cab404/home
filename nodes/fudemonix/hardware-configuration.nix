{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  # Hardware config?
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi = {
    enable = true;
    version = 3;
    uboot.enable = true;
    firmwareConfig = ''
      force_turbo=1
    '';
  };

  boot.supportedFilesystems = lib.mkForce [ ];

}
