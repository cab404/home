params @ { config, pkgs, lib, ... }:
let
  enableThings = with builtins;
    things: overrides:
    if length things == 0
    then overrides
    else lib.recursiveUpdate (enableThings (tail things) overrides) {
      "${head things}".enable = true;
    };
  _env = import ./secret/env.nix;
in
{

  i18n = {
    # Dimmed Monokai
    consoleColors = [
        "3A3C43" "BE3E48" "869A3A" "C4A535" "4E76A1" "855B8D" "568EA3" "B8BCB9"
        "888987" "FB001E" "0E712E" "C37033" "176CE3" "FB0067" "2D6F6C" "FCFFB8"
    ];
    consoleFont = "Lat2-Terminus16";
    defaultLocale = "en_US.UTF-8";
    consoleUseXkbConfig = true; # ctrl:nocaps at last
  };

  time.timeZone = _env.timeZone;

  nix = {
    trustedUsers = [ "root" _env.username ];
  };

  nixpkgs.overlays = [
    (self: super: {
      _env = import ./secret/env.nix;
      _libs = import ./lib.nix params;
    })
  ];

  nixpkgs.config = {
    checkMeta = true;
    android_sdk.accept_license = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = _env.hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  security = {
    sudo.extraRules = [
      { groups = [ "wheel" ]; runAs="ALL"; commands = [ { command="ALL"; options=["NOPASSWD" ]; } ]; }
    ];
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
    users."${_env.username}" = {
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
  ]);

}
