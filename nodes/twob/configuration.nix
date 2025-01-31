{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in { # %%MODULE_HEADER%%
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./builder.nix

    <modules/recipes/ssh.nix>
    <modules/recipes/ssh-persist.nix>
    <modules/recipes/substituters.nix>
    <modules/recipes/tailscale.nix>
    <modules/core.nix>
    <modules/home-manager>

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

}
