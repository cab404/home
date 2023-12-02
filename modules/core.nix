# This is a small dump of useful options I prefer everywhere.

{ config, pkgs, lib, prelude, ... }: with prelude; let __findFile = prelude.__findFile; in {

  # ====== Packages

  imports = [
    ./barecore.nix
  ];

  environment.defaultPackages = (with pkgs; [
    # this section is a tribute to my PEP-8 hatred
    ntfsprogs btrfs-progs
  ]);

  # ====== NixOS system-level stuff

  # In the grim dark future there is only NixOS
  # system.stateVersion = "40000.00";
  # (enables all of the unstable features pretty much always)

  boot = lib.mkDefault {
    kernelPackages = pkgs.linuxPackages_testing;
    kernelParams = [ "quiet" ];
  };


  # ====== Basic tty and shell look-and-feel configuration and hacks

  console = {
    colors = [
      "3A3C43" "BE3E48" "869A3A" "C4A535"
      "4E76A1" "855B8D" "568EA3" "B8BCB9"
      "888987" "FB001E" "0E712E" "C37033"
      "176CE3" "FB0067" "2D6F6C" "FCFFB8"
    ];
    font = "Lat2-Terminus16";
    useXkbConfig = true; # ctrl:nocaps at last
  };

  i18n.defaultLocale = "C.UTF-8";

  services.xserver = {
    layout = "us,ru";
    xkbOptions = "ctrl:nocaps,lv3:ralt_switch_multikey,misc:typo,grp:rctrl_switch";
  };


  # ====== Security keys support

  hardware.nitrokey.enable = true;
  services.udev.extraRules = ''
    # GNUK token
    ATTR{idVendor}=="234b", ATTR{idProduct}=="0000", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP="wheel"
  '';

  # ====== Core services

  services = {

    # avahi = on;
    fwupd = on // {
      extraRemotes = [ "lvfs-testing" ];
    };

  };

  security = {
    polkit = on;
    tpm2 = on;
  };

}
