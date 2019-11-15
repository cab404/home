{ config, pkgs, options, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./hw/dell-latitude-5400.nix
    (import (builtins.fetchGit {
      url = "https://github.com/rycee/home-manager.git";
      ref = "master";}) {}).nixos
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
    # Disk configuration cause hw configuration generator can't.
    initrd.luks.devices = {
      rootfs = {
        device = "/dev/sda2";
        preLVM = true;
        allowDiscards = true;
      };
    };

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

  services = {
    ntp.enable = true;
    locate.enable = true;
    openssh.enable = true;
    gnome3.core-os-services.enable = true;

    actkbd = {
      enable = true;
      bindings = [
        {keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
        {keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
      ];
    };

    udev.packages = [
      pkgs.android-udev-rules
    ];

    xserver = {

      enable = true;
      libinput.enable = true;
      libinput.tapping = false;
      wacom.enable = true;

      layout = "us,ru";
      xkbOptions = "ctrl:nocaps, grp:switch, compose:prsc";

      displayManager.lightdm.enable = true;
      displayManager.lightdm.greeter.enable = true;

    };
  };

  # == Sound
  sound.enable = true;
  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      daemon.config = {
        flat-volumes = "no";
      };
    };
    bluetooth.enable = true;
  };

  environment.systemPackages = (with pkgs; [
    curl vim htop git tmux
    usbutils pciutils unzip
    ntfsprogs btrfs-progs
    nmap arp-scan
  ]);

  programs.light.enable = true;
  programs.seahorse.enable = true;
  virtualisation.docker.enable = true;

  powerManagement.powertop.enable = true;

  users = {

    groups = {
      plugdev = {};
    };

    users.cab = {
      isNormalUser = true;
      extraGroups = [
        "plugdev" "docker"
        "wheel" "containers"
        "networkmanager"
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
