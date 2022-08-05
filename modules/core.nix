args @ { config, pkgs, lib, ... }:
with import ../lib.nix args; {

  system.stateVersion = "22.05";

  require = [ ./options.nix ];

  console = {
    colors = [
        "3A3C43" "BE3E48" "869A3A" "C4A535" "4E76A1" "855B8D" "568EA3" "B8BCB9"
        "888987" "FB001E" "0E712E" "C37033" "176CE3" "FB0067" "2D6F6C" "FCFFB8"
    ];
    font = "Lat2-Terminus16";
    useXkbConfig = true; # ctrl:nocaps at last
  };

  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    package = pkgs.nixUnstable;
    settings = {
      trusted-users = [ "root" config._.user ];
      experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
    };
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

  boot = {
    kernelPackages = pkgs.linuxPackages_testing;
    plymouth = on;
    kernelParams = [ "quiet" ];
  };

  hardware.nitrokey.enable = true;

  services = {

    avahi = on;
    fwupd = on;

    udev.extraRules = ''
    # GNUK token
    GROUPS=="wheel", ATTR{idVendor}=="234b", ATTR{idProduct}=="0000", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg"
    '';

    openssh = on // {
      passwordAuthentication = false;
    };

    xserver = {
      layout = "us,ru";
      xkbOptions = "ctrl:nocaps,lv3:ralt_switch_multikey,misc:typo,grp:win_space_toggle";
    };

  };

  users = {
    mutableUsers = false;
    users."${config._.user}" = {
      isNormalUser = true;
      extraGroups = [
        "plugdev" "wheel" "nitrokey"
        "containers" "networkmanager"
        "dialout" "video"
      ];
      shell = pkgs.zsh;
    };
    users.root.shell = pkgs.zsh;
  };

  security = {
    polkit = on;
    tpm2 = on;
  };

  environment.shells = [ pkgs.zsh ];
  environment.pathsToLink = [ "/share/zsh" ];
  environment.variables = {
    EDITOR = "vi";
  };
  environment.defaultPackages = (with pkgs; [
    # this section is a tribute to my PEP-8 hatred
    curl htop git tmux rsync hexedit # find one which does not fit
    ntfsprogs btrfs-progs  # why aren't those there by default?
    killall usbutils pciutils unzip  # WHY AREN'T THOSE THERE BY DEFAULT?
    nmap arp-scan
    emacs # an editor, too
    nix-index  # woo, search in nix packages files!
    nix-zsh-completions zsh-completions  # systemctl ena<TAB>... AAAAGH
  ]);


}
