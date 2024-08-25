{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in { # %%MODULE_HEADER%%
  imports =
    [
      <modules/recipes/ssh.nix>
      <modules/recipes/ssh-persist.nix>
      <modules/recipes/substituters.nix>
      <modules/recipes/tailscale.nix>
      <modules/core.nix>
      <modules/home-manager>

      (import <nodes/keter/wgbond.nix>).defaults
      (import <nodes/keter/wgbond.nix>).c1
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.services."NetworkManager-wait-online".wantedBy = lib.mkForce [];

  networking.hostName = "c1";
  _.user = "cab";

  boot.loader.timeout = 0;
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  services.fstrim.enable = true;

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

  networking = {
    firewall = on // {
      allowedTCPPorts = [ 80 443 7000 ];
      allowedUDPPorts = [ 41641 42232 61111 ];
      trustedInterfaces = [ "tailscale0" "keter" ];
    };
    # constant disconnects and weird internets are the reason i use nm.
    # it's really versatile, and aims to just get the client to the internet no matter what
    # and that's what I want with this machine
    networkmanager = on;
  };


  nix.settings.system-features = [ "gccarch-alderlake" "benchmark" "big-parallel" "ca-derivations" "kvm" "nixos-test"  ];


  # services.tor = {
  #   enable = true;
  #   relay = {
  #     enable = true;
  #     role = "relay";
  #   };
  #   settings = {
  #     BandwidthBurst = 800 * 1024;
  #     BandwidthRate = 500 * 1024;
  #     Nickname = "mnfrdmcx";
  #     # Address = "cab404.ru";
  #     # ORPort = 143;
  #   };
  # };

  users.users = {
    "${config._.user}" = {
      extraGroups = [ "docker" ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

}
