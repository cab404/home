params @ { config, pkgs, lib, ... }:
let
  enableThings = with builtins;
    things: overrides:
    if length things == 0
    then overrides
    else lib.recursiveUpdate (enableThings (tail things) overrides) {
      "${head things}".enable = true;
    };
  _ = config._;
in
{

  require = [ ./env.nix ];

  i18n.defaultLocale = "en_US.UTF-8";

  nix.trustedUsers = [ "root" _.user ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = false;
  };

  services = enableThings [
    "openssh"
  ] {
    openssh = {
      passwordAuthentication = false;
    };
  };

  users = {
    mutableUsers = false;
    users."${_.user}" = {
      isNormalUser = true;
      extraGroups = [
        "plugdev" "wheel" "containers"
        "networkmanager" "dialout"
      ];
      shell = pkgs.zsh;
    };
  };

  environment.pathsToLink = [ "/share/zsh" ];
  environment.systemPackages = (with pkgs; [
    # this section is a tribute to my PEP-8 hatred
    curl vim htop git tmux hexedit # find one which does not fit
    ntfsprogs btrfs-progs  # why aren't those there by default?
    killall usbutils pciutils unzip  # WHY AREN'T THOSE THERE BY DEFAULT?
    nmap arp-scan
    nix-index  # woo, search in nix packages files!
    nix-zsh-completions zsh-completions  # systemctl ena<TAB>... AAAAGH
    cachix # cause I need hie in finite amount of time
  ]);

}
