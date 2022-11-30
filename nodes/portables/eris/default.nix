args@{ inputs, lib, config, pkgs, ... }: with import ../../../lib.nix args; {

  imports = [
    ../../../modules/home-manager
    ../../../modules/sway/system.nix

    # device-specific
    inputs.nixos-hw.nixosModules.framework-12th-gen-intel

    # eris-specific
    ./system.nix

    # usecase-specific
    ../../../modules/electronics.nix
  ];

  programs.nix-ld.enable = true;
  environment.variables = {
     NIX_LD = pkgs.stdenv.cc.bintools.dynamicLinker;
  };

  networking.firewall = on;

  boot.tmpOnTmpfs = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "eris";

  # systemd.coredump.enable = true;

  # Young streamer's kit (don't mistake with adolescent kit, that would be tiktok)
  programs.gphoto2 = on;
  users.users.cab.extraGroups = [ "camera" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  # I guess if I have dwarffs in this system, might as well.
  # environment.defaultPackages = [ pkgs.gdb ];

  services.pcscd = on;
  services.udev.packages = with pkgs; [ qFlipper openhantek6022 ];

  # This also opens all the necessary ports
  programs.kdeconnect = on;

  _.user = "cab";

  i18n.defaultLocale = "C.UTF-8";

}
