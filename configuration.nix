{ config, pkgs, options, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  i18n = { consoleFont = "Lat2-Terminus16"; consoleKeyMap = "us"; defaultLocale = "en_US.UTF-8"; };
  time.timeZone = "Europe/Moscow";
  services.ntp.enable = true;

  nix.autoOptimiseStore = true;
  nixpkgs.config = {
    # allowUnfree = true;
    android_sdk.accept_license = true;
  };

  # Disk configuration cause hw configuration generator can't.
  boot.initrd.luks.cryptoModules = [ "aes" "xts" "plain64" ];
  boot.initrd.luks.devices = {
    rootfs = {
      device = "/dev/sda2";
      preLVM = true;
      allowDiscards = true;
    };
  };

  networking.hostName = "yuna";
  networking.firewall.enable = true;
  networking.networkmanager.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "i915.alpha_support=1"
    "i915.fastboot=1"
    "i915.enable_fbc=1"
    "i915.enable_psr=1"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  security.sudo.extraRules = [
    { groups = [ "wheel" ]; runAs="ALL"; commands = [ { command="ALL"; options=["NOPASSWD" "SETENV" ]; } ]; }
  ];

  services.openssh.enable = true;
  sound.enable = true;

  hardware = {
    pulseaudio = { enable = true;
      package = pkgs.pulseaudioFull;
    };
    bluetooth.enable = true;
  };

  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      {keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      {keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
    ];
  };

  services.dbus.packages = with pkgs; [ gnome3.dconf ];
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome3 = {
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
  };

  virtualisation.docker.enable = true;

  services.xserver = {

    enable = true;
    libinput.enable = true;
    libinput.tapping = false;
    wacom.enable = true;

    layout = "us,ru";
    xkbOptions = "ctrl:nocaps, grp:switch, compose:prsc";
    
    displayManager.lightdm.enable = true;
    displayManager.lightdm.greeter.enable = true;

  };

  users.users.cab = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" "containers" "networkmanager" ];
    shell = pkgs.zsh;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}
