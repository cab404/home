{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in { # %%MODULE_HEADER%%

  imports = [
    <modules/recipes/ssh.nix>
    <modules/recipes/ssh-persist.nix>
    <modules/recipes/substituters.nix>
    <modules/recipes/tailscale.nix>
    <modules/core.nix>
    <modules/home-manager>

    # inputs.subspace.nixosModule
    # inputs.dwarffs.nixosModules.dwarffs
    # <modules/sway/system.nix>
    # <modules/home-manager>

  ];

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # tailscale
  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  systemd.network.wait-online.enable = false;

  boot.tmpOnTmpfs = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "yuna";

  # systemd.coredump.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # This also opens all the necessary ports
  programs.kdeconnect = on;

  _.user = "cab";

  i18n.defaultLocale = "C.UTF-8";

}
