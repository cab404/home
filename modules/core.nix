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

  documentation.man = {
    # generateCaches = true;
  };

  # ====== Security keys support

  hardware.nitrokey.enable = true;
  services.udev.extraRules = ''
    # GNUK token
    ATTR{idVendor}=="234b", ATTR{idProduct}=="0000", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP="wheel"
  '';

  # ====== Core services

  services = {

    avahi = on;
    fwupd = on // {
      extraRemotes = [ "lvfs-testing" ];
    };

  };

  security = {
    polkit = on;
    tpm2 = on;
  };

}
