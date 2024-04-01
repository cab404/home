# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./builder.nix
    # ./jukebox.nix
    # ./pipewire.nix
    # ./router.nix
    # ./extproxy.nix
  ];

  networking.hostName = "twob";
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  time.timeZone = "Europe/Moscow";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.tailscale.enable = true;

  services.fwupd.enable = true;
  networking.firewall.enable = false;

  services.minecraft-server.enable = true;
  services.minecraft-server.eula = true;
  services.minecraft-server.openFirewall = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
             "minecraft-server"
  ];

  nix.extraOptions = "experimental-features = nix-command flakes";
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
    banner = ''
      I wanna be your build bitch, top me, use me!
    '';
  };

  users = {
    users.root = {
      # password = "12345";
      extraGroups = [ "wheel" "pipewire" "dialout" "usb" "plugdev" "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKIABDEIeccdbZwTgxhkVUIyZa8fx9uyiE0I2S9t4x1 cab404@meow2"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXU0K0o7IeRo1wtUQFoGDMwnbV2zHjSzTi1d+QpUmXr new_gitkey@flipper.hax"
      ];
    };
    users.cab = {
      isNormalUser = true;
      # password = "12345";
      extraGroups =
        [ "wheel" "pipewire" "audio" "dialout" "usb" "plugdev" "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKIABDEIeccdbZwTgxhkVUIyZa8fx9uyiE0I2S9t4x1 cab404@meow2"
      ];
    };
    mutableUsers = false;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    pulsemixer
    git
    screen
    btop
    bash-completion
    stress
    cpufrequtils
  ];

  system.stateVersion = "22.11";

}
