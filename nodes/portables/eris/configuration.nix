{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in { # %%MODULE_HEADER%%

  imports = [
    <modules/gnome/system.nix>
    <modules/home-manager>

    # device-specific
    inputs.nixos-hw.nixosModules.framework-12th-gen-intel

    # eris-specific
    ./hardware-configuration.nix

    # usecase-specific
    <modules/recipes/ssh.nix>
    <modules/recipes/ssh-persist.nix>
    <modules/recipes/streaming.nix>
    <modules/recipes/audio.nix>
    <modules/recipes/nixld.nix>
    <modules/recipes/hwhack.nix>
    <modules/recipes/known-keys.nix>
    <modules/recipes/oculus.nix>
  ];

  networking = {
    networkmanager.dns = "systemd-resolved";
    networkmanager.wifi.backend = "iwd";
    networkmanager.wifi.powersave = false;
    firewall = on // {
      checkReversePath = "loose";
    };
  };
  services.resolved = {
    enable = true;
    fallbackDns = [
      "8.8.8.8" "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001"
    ];
  };
  services.tailscale.enable = true;

  # In the grim dark future there is only NixOS
  system.stateVersion = lib.mkForce "40000.05";
  # (enables all of the unstable features pretty much always)


  networking.hostName = "eris";
  _.user = "cab";
  i18n.defaultLocale = "C.UTF-8";
  home-manager.users.cab = { imports = [ ./home.nix ]; };
  users.users.cab.passwordFile = "/secrets/password";
  users.users.root.passwordFile = "/secrets/password";

  boot.tmpOnTmpfs = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.udev.packages = with pkgs; [ qFlipper ];

  # This also opens all the necessary ports
  programs.kdeconnect = on;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-run"
    "steam-original"
  ];

}
