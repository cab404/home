{ config, pkgs, inputs, lib, ... }: {
  system.name = "c1";
  networking.hostName = config.system.name;

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./hydra.nix
      # ./secrets.nix
      ../ssh.nix
      ../../../modules/core.nix
      ../../../modules/home-manager
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useDHCP = false;
  networking.interfaces.enp7s0.useDHCP = true;

  boot.loader.timeout = 0;
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    wget
    vim
    cryptsetup
    docker-compose
    btrfs-progs
    thin-provisioning-tools
    hexedit
    git
    screen
  ];

  services.cron.enable = true;

  virtualisation.docker.enable = true;
  systemd.services.docker.wantedBy = [ ];

  networking.firewall.enable = false;

  # constant disconnects and weird internets are the reason i use nm.
  # it's really versatile, and aims to just get the client to the internet no matter what
  # and that's what I want with this machine
  networking.networkmanager.enable = true;

  services.tor = {
    enable = true;
    relay = {
      enable = true;
      role = "relay";
    };
    settings = {
      BandwidthBurst = 800 * 1024;
      BandwidthRate = 500 * 1024;
      Nickname = "mnfrdmcx";
      # Address = "cab404.ru";
      # ORPort = 143;
    };
  };

  users.users = {
    "${config._.user}" = {
      extraGroups = [ "docker" ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

}
