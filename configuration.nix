{ config, pkgs, options, lib, ... }:
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
  imports = [
    ./hardware-configuration.nix
    ./secret/system.nix
    ./hw/dell-latitude-5400.nix
  ];

  # Time
  i18n = { consoleFont = "Lat2-Terminus16"; consoleKeyMap = "us"; defaultLocale = "en_US.UTF-8"; };
  time.timeZone = "Europe/Moscow";

  nix = {
    trustedUsers = [ "root" "cab" ];
    useSandbox = true;
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config = {
    # allowUnfree = true;
    android_sdk.accept_license = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "yuna";
    networkmanager.enable = true;
  };

  security = {
    allowUserNamespaces = true;
    sudo.extraRules = [
      { groups = [ "wheel" ]; runAs="ALL"; commands = [ { command="ALL"; options=["NOPASSWD" "SETENV" ]; } ]; }
    ];
  };

  services = enableThings [
    "ntp" "locate" "openssh" "upower" "printing" "fwupd"
    "tor" "actkbd" "xserver" "throttled" "gnunet"
  ] {

    openssh = {
      passwordAuthentication = false;
    };

    logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "suspend";
    };

    actkbd = {
      bindings = [
        {keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
        {keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
      ];
    };

    udev.packages = [
      pkgs.android-udev-rules
    ];

    xserver = {

      libinput.enable = true;
      libinput.tapping = false;
      wacom.enable = true;

      layout = "us,ru";
      xkbOptions = "ctrl:nocaps, grp:switch";

      displayManager.slim = {
        enable = true;
        autoLogin = true;
        defaultUser = "cab";
      };

    };

    # blueman-applet screams at me without it
    dbus.packages = [ pkgs.blueman ];

    tor = {
      controlSocket.enable = true;
      client.enable = true;
    };

  };

  # == Sound
  sound.enable = true;
  hardware = {
    cpu.intel.updateMicrocode = true;
    opengl = {
      enable = true;
    };
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      zeroconf.discovery.enable = true;
      daemon.config = {
        flat-volumes = "no";
      };
    };
    bluetooth.enable = true;
  };

  environment.pathsToLink = [ "/share/zsh" ];
  environment.systemPackages = (with pkgs; [
    # this section is a tribute to my PEP-8 hatred

    curl vim htop git tmux  # find one which does not fit

    usbutils pciutils unzip  # WHY AREN'T THOSE THERE BY DEFAULT?

    ntfsprogs btrfs-progs  # why aren't those there by default?

    nmap arp-scan  # cause there's nothing to do at airports

    nix-index  # woo, search in nix packages files!

    gnome3.dconf xfce.xfconf  # programs <3 configs

    nix-zsh-completions zsh-completions  # systemctl ena<TAB>... AAAAGH

  ]);

  programs = enableThings [
    "light" # brightness control
    "plotinus" # command pallet that doesn't work yet for some reason
    "wireshark" # should create some missing groups
  ] {};

  virtualisation.docker.enable = true;
  powerManagement.powertop.enable = true;

  users = {
    mutableUsers = false;

    users.cab = {
      isNormalUser = true;
      extraGroups = [
        "plugdev" "docker"
        "wheel" "containers"
        "networkmanager" "tor"
        "avahi" "wireshark"
      ];
      shell = pkgs.zsh;
    };

  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
