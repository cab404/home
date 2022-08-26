args@{ inputs, config, pkgs, ... }: with import ../../../lib.nix args; {

  imports = [
    # inputs.subspace.nixosModule
    # inputs.dwarffs.nixosModules.dwarffs
    ../../../modules/home-manager
    ../../../modules/sway/system.nix

    # device-specific
    ../../dell-latitude-5400.nix
    # yuna-specific
    ./system.nix
    ./serokell.nix
  ];

  networking.firewall.enable = true;

  boot.tmpOnTmpfs = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "yuna";

  # systemd.coredump.enable = true;

  # Young streamer's kit (don't mistake with adolescent kit, that would be tiktok)
  programs.gphoto2.enable = true;
  users.users.cab.extraGroups = [ "camera" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  # I guess if I have dwarffs in this system, might as well.
  # environment.defaultPackages = [ pkgs.gdb ];

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.qFlipper ];
  # This also opens all the necessary ports
  programs.kdeconnect = on;

  _.user = "cab";

  nixpkgs.overlays = [
    # inputs.nix.overlay
    # inputs.neovim-nightly.overlay
    # inputs.emacs-overlay.overlay
  ];

  i18n.defaultLocale = "C.UTF-8";

}
