args@{ inputs, lib, config, pkgs, ... }: with import "${inputs.self}/lib.nix" args; {
  imports = [
    "${inputs.self}/modules/sway/system.nix"
    "${inputs.self}/modules/home-manager"

    # device-specific
    inputs.nixos-hw.nixosModules.framework-12th-gen-intel

    # eris-specific
    ./hardware-configuration.nix

    # usecase-specific
    "${inputs.self}/modules/recipes/streaming.nix"
    "${inputs.self}/modules/recipes/audio.nix"
    "${inputs.self}/modules/recipes/nixld.nix"
    "${inputs.self}/modules/recipes/hwhack.nix"
  ];

  # dns = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
  # networking.wg-quick.interfaces."keter".configFile = "/secrets/keter.conf";
  # networking.hosts = {
  #   "10.0.10.2" = [ "c1.keter" "cab404.ru" "nextcloud.cab404.ru" ];
  # };

  # In the grim dark future there is only NixOS
  system.stateVersion = lib.mkForce "40000.05";
  # (enables all of the unstable features pretty much always)
  networking.hostName = "eris";
  _.user = "cab";
  i18n.defaultLocale = "C.UTF-8";
  home-manager.users.cab = { imports = [ ./home.nix ]; };
  users.users.cab.passwordFile = "/secrets/password";
  users.users.root.passwordFile = "/secrets/password";


  networking.firewall = on;

  programs.ssh = {
    extraConfig = ''
      Host *
        ControlMaster auto
        ControlPath ~/.ssh/master-%r@%n:%p
        ControlPersist 2m
    '';
  };

  boot.tmpOnTmpfs = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.udev.packages = with pkgs; [ qFlipper ];

  # This also opens all the necessary ports
  programs.kdeconnect = on;

}
