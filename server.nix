{ config, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.autoUpgrade.enable = true;

  networking = {
    hostName = "c1";
    useDHCP = false;
    interfaces.enp7s0.useDHCP = true;
  };

  time.timeZone = "Europe/Moscow";

  nix.trustedUsers = [ "builder" ];

  boot.loader.timeout = 0;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    wget vim

    cryptsetup
    btrfs-progs
    thin-provisioning-tools

    docker-compose
    hexedit git
  ];

  networking = {
    wireguard.enable = true;
    wireguard.interfaces = {
      wg0 = {
        privateKey = "oEbwIwXZ7j0gmUk2i+dPHKpDsUki3eF0+Jqh1ZfITFU=";
        ips = [ "10.0.0.2/32" ];
        listenPort = 64000;
        peers = [
          {
            allowedIPs = ["10.0.0.0/24"];
            persistentKeepalive = 30;
            endpoint = "185.247.118.200:64000";
            publicKey = "om+CPAhwXcpTI4EzzmfCEPrbHiNo4fMF9BazZFeziFo=";
          }
        ];
      };
    };
  };


  services.cron.enable = true;
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  virtualisation.docker.enable = true;
  systemd.services.docker.wantedBy = [];
  networking.firewall.enable = false;

  users.users.cab = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" ];
  };

  users.users.builder = {
    isNormalUser = true;
    extraGroups = [ ];
  };

  system.stateVersion = "19.09"; # Did you read the comment?

}
