{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in { # %%MODULE_HEADER%%

  # In the grim dark future there is only NixOS
  system.stateVersion = lib.mkForce "40000.05";
  # (enables all of the unstable features pretty much always)

  home-manager.users.cab = { imports = [ ./home.nix ]; };

  users.users.cab.passwordFile = "/secrets/password";
  users.users.root.passwordFile = "/secrets/password";

  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "keter-builders:tkX3vAac9+Zg9v0hGcCfuPBkykQm/PNQ4/QNpz4Ulgc="
  ];

  # dns = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
  # networking.wg-quick.interfaces."keter".configFile = "/secrets/keter.conf";
  # networking.hosts = {
  #   "10.0.10.2" = [ "c1.keter" "cab404.ru" "nextcloud.cab404.ru" ];
  # };

  programs.ssh = {
    extraConfig = ''
      Host *
        ControlMaster auto
        ControlPath ~/.ssh/master-%r@%n:%p
        ControlPersist 2m
    '';
  };


  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;


}
