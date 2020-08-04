params @ { config, pkgs, lib, ... }:
let
  enableThings = with builtins;
    things: overrides:
    if length things == 0
    then overrides
    else lib.recursiveUpdate (enableThings (tail things) overrides) {
      "${head things}".enable = true;
    };
in
{

  require = [ ./env.nix ];

  console = {
    colors = [
        "3A3C43" "BE3E48" "869A3A" "C4A535" "4E76A1" "855B8D" "568EA3" "B8BCB9"
        "888987" "FB001E" "0E712E" "C37033" "176CE3" "FB0067" "2D6F6C" "FCFFB8"
    ];
    font = "Lat2-Terminus16";
    useXkbConfig = true; # ctrl:nocaps at last
  };

  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    trustedUsers = [ "root" config._.user ];
  };


  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = false;
  };

  hardware.nitrokey.enable = true;

  services = enableThings [
    "openssh" "fwupd" "upower"
  ] {

    udev.extraRules = ''
    GROUPS=="wheel", ATTR{idVendor}=="234b", ATTR{idProduct}=="0000", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg"
    '';

    openssh = {
      passwordAuthentication = false;
    };

    xserver = {
      layout = "us,ru";
      xkbOptions = "ctrl:nocaps, grp:switch";
    };

  };

  users = {
    mutableUsers = false;
    users."${config._.user}" = {
      isNormalUser = true;
      extraGroups = [
        "plugdev" "wheel" "nitrokey"
        "containers" "networkmanager"
        "dialout"
      ];
      shell = pkgs.zsh;
    };
  };

  environment.pathsToLink = [ "/share/zsh" ];
  environment.systemPackages = (with pkgs; [
    # this section is a tribute to my PEP-8 hatred
    curl vim htop git tmux hexedit # find one which does not fit
    ntfsprogs btrfs-progs  # why aren't those there by default?
    killall usbutils pciutils unzip  # WHY AREN'T THOSE THERE BY DEFAULT?
    nmap arp-scan
    nix-index  # woo, search in nix packages files!
    nix-zsh-completions zsh-completions  # systemctl ena<TAB>... AAAAGH
    cachix # cause I need hie in finite amount of time
  ]);

}
