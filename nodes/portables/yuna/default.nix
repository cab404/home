args@{ inputs, lib, config, pkgs, ... }: with import ../../../lib.nix args; {

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
    ./lifelogging.nix
  ];


  # This is a story of a war. A war so fierce and fiery, so pointless and dumb,
  # that sides forgotten out of spite why they are even fighting.
  #
  # Pinning side wants to link the world and every binary within directly with
  # its dependencies, so there could never ever be a single environment where
  # incorrect behavior happens. Each binary knows the exact path to each shared
  # library it's using, dlopens are patched, pre-built binaries are patchelf-ed
  # and everything is pure and is under control.
  #
  # Dynamic linking side wants to use binaries as they are, without the need to
  # pin everything you've downloaded — thus introducing default linker —
  # impurity and a way to get binaries to behave inpredictably in otherwise
  # pristine system. You get to update your openssl without rebuilding anything
  # — reminding us of older, barbaric times you've had `/usr/lib`.
  #
  # Nix involves you in this war on the purist pinning side by default, leaving
  # you no obvious choice.
  #
  # You can have both! Nix-ld shims in, and provides a usable ld binary, thus
  # enabling dynamically linked programs to operate on NixOS.
  #
  # Of course, you lose purity in libraries in any program you've downloaded
  # from the internet without patching — but you made your choice after clicking
  # it's link. After all, we already did that to cacerts.
  programs.nix-ld.enable = true;
  environment.variables = {
    NIX_LD = pkgs.stdenv.cc.bintools.dynamicLinker;
  };

  networking.firewall = on;

  boot.tmpOnTmpfs = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "yuna";

  # systemd.coredump.enable = true;

  # Young streamer's kit (don't mistake with adolescent kit, that would be tiktok)
  programs.gphoto2 = on;
  users.users.cab.extraGroups = [ "camera" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  # I guess if I have dwarffs in this system, might as well.
  # environment.defaultPackages = [ pkgs.gdb ];

  services.pcscd = on;
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
