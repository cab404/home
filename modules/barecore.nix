# This is a small dump of useful options I prefer everywhere.

{ config, pkgs, lib, prelude, ... }: with prelude; let __findFile = prelude.__findFile; in {

  # ====== Packages

  environment.defaultPackages = (with pkgs; [
    # this section is a tribute to my PEP-8 hatred
    curl htop git tmux  # why aren't those there by default?
    killall usbutils pciutils zip unzip # WHY AREN'T THOSE THERE BY DEFAULT?
    nmap arp-scan rsync

    helix vim

    nix-index # woo, search in nix packages files!

    # nix-zsh-completions
    # zsh-completions # systemctl ena<TAB>... AAAAGH
    # nix-bash-completions
    # bash-completion
    mosh

    waypipe
  ]);

  # ====== NixOS system-level stuff

  system.stateVersion = "23.11";

  # In the grim dark future there is only NixOS
  # system.stateVersion = "40000.00";
  # (enables all of the unstable features pretty much always)

  require = [ ./options.nix ];
  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      trusted-users = [ "root" config._.user ];
      experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
    };

    # This pins nixpkgs from the flake.lock system-wide both in registry and NIX_PATH
    nixPath = [ "nixpkgs=${pkgs.path}" ];
    registry =
      let
        lock = (with builtins; fromJSON (readFile ../flake.lock));
      in
      {
        nixpkgs =  lib.mkForce (with lock.nodes.${lock.nodes.${lock.root}.inputs.nixpkgs}; {
          from = { id = "nixpkgs"; type = "indirect"; };
          to = locked;
        });
      };
  };

  # ====== User configuration

  users = {
    mutableUsers = false;
    users."${config._.user}" = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "containers"
        "networkmanager"
        "plugdev"
        "dialout"
        "video"
      ];
      shell = pkgs.nushell;
    };
    users.root.shell = pkgs.nushell;
    defaultUserShell = pkgs.nushell;
  };

  # ====== Kernel

  boot = lib.mkDefault {
    kernelParams = [ "quiet" ];
  };

  i18n.defaultLocale = "C.UTF-8";

  services.xserver.xkb = {
    layout = "us,ru";
    options = "ctrl:nocaps,lv3:ralt_switch_multikey,misc:typo,grp:rctrl_switch";
  };

  programs = {
    zsh = on // {
      enableCompletion = true;
    };
    bash.completion.enable = true;
  };

  environment.variables = { EDITOR = "hx"; };


  # ====== Core services
  programs.mosh.enable = true;
  services = {

    openssh = on // {
      settings.PasswordAuthentication = false;
    };

  };

}
