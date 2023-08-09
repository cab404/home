# This is a small dump of useful options I prefer everywhere.

{ config, pkgs, lib, prelude, ... }: with prelude; let __findFile = prelude.__findFile; in {

  nixpkgs.config.checkMeta = true;

  # ====== Packages

  environment.defaultPackages = (with pkgs; [
    # this section is a tribute to my PEP-8 hatred
    curl htop git tmux ntfsprogs btrfs-progs # why aren't those there by default?
    killall usbutils pciutils zip unzip # WHY AREN'T THOSE THERE BY DEFAULT?
    nmap arp-scan rsync

    helix vim 
    
    nix-index # woo, search in nix packages files!

    nix-zsh-completions
    zsh-completions # systemctl ena<TAB>... AAAAGH
    nix-bash-completions
    bash-completion

    waypipe # cause reasons
  ]);

  # ====== NixOS system-level stuff

  system.stateVersion = "22.05";

  # In the grim dark future there is only NixOS
  # system.stateVersion = "40000.00";
  # (enables all of the unstable features pretty much always)

  require = [ ./options.nix ];
  nix = {
    package = pkgs.nixUnstable;
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
        nixpkgs = with lock.nodes.${lock.nodes.${lock.root}.inputs.nixpkgs}; {
          from = { id = "nixpkgs"; type = "indirect"; };
          to = locked;
        };
      };
  };

  # ====== User configuration

  users = {
    mutableUsers = false;
    users."${config._.user}" = {
      isNormalUser = true;
      extraGroups = [
        "plugdev"
        "wheel"
        "nitrokey"
        "containers"
        "networkmanager"
        "dialout"
        "video"
      ];
      shell = pkgs.zsh;
    };
    users.root.shell = pkgs.zsh;
  };

  # ====== Kernel

  boot = lib.mkDefault {
    kernelPackages = pkgs.linuxPackages_testing;
    kernelParams = [ "quiet" ];
  };


  # ====== Basic tty and shell look-and-feel configuration and hacks

  console = {
    colors = [
      "3A3C43" "BE3E48" "869A3A" "C4A535"
      "4E76A1" "855B8D" "568EA3" "B8BCB9"
      "888987" "FB001E" "0E712E" "C37033"
      "176CE3" "FB0067" "2D6F6C" "FCFFB8"
    ];
    font = "Lat2-Terminus16";
    useXkbConfig = true; # ctrl:nocaps at last
  };

  i18n.defaultLocale = "C.UTF-8";

  services.xserver = {
    layout = "us,ru";
    xkbOptions = "ctrl:nocaps,lv3:ralt_switch_multikey,misc:typo,grp:rctrl_switch";
  };

  programs = {
    zsh = on // {
      enableCompletion = true;
    };
    bash.enableCompletion = true;
  };

  environment.pathsToLink = [ "/share/zsh" ];
  environment.variables = { EDITOR = "hx"; };

  # ====== Security keys support

  hardware.nitrokey.enable = true;
  services.udev.extraRules = ''
    # GNUK token
    ATTR{idVendor}=="234b", ATTR{idProduct}=="0000", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP="wheel"
  '';

  # ====== Core services

  services = {

    avahi = on;
    fwupd = on // {
      extraRemotes = [ "lvfs-testing" ];
    };

    openssh = on // {
      settings.PasswordAuthentication = false;
    };

  };

  security = {
    polkit = on;
    tpm2 = on;
  };

}
