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
    <modules/podman.nix>

  ];

  _.user = "cab";
  networking.hostName = "twob";
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  time.timeZone = "Europe/Moscow";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.tailscale.enable = true;

  services.fwupd.enable = true;
  networking.firewall.enable = false;

  nix.settings.system-features = [ "gccarch-alderlake" "benchmark" "big-parallel" "ca-derivations" "kvm" "nixos-test" ];
  nix.extraOptions = "experimental-features = nix-command flakes ca-derivations";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
    banner = ''
      I wanna be your build bitch  (,,>﹏<,,)
      (≧ヮ≦) h-top me, f-use me!
    '';
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
    podman-compose
  ];

}
