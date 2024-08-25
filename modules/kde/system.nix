{ config, pkgs, lib, prelude, ... }: with prelude; let __findFile = prelude.__findFile; in {

   home-manager.users.${config._.user}.imports = [
    ./home.nix
  ];

  imports = [
    ../graphical.nix
  ];

  environment.homeBinInPath = true; # ..?

  environment.defaultPackages = (with pkgs; [
    wl-clipboard
    wayland-utils
    glxinfo
    vulkan-tools

    maliit-keyboard

    # ffffffffucking nix!
    # quodlibet-full

  ]) ++ (with pkgs.kdePackages; [
    # I have no clue, why akonadi can't find its plugins with a basic packaging,
    # but merkuro manages to launch it correctly. Something to take a look in nixpkgs.
    merkuro
    akonadi-calendar-tools
    akonadi
    kontact
    kclock

    filelight
    kcharselect

    kdenetwork-filesharing

    partitionmanager
    kpmcore

  ]);

  programs.kdeconnect.enable = true;

  # yaaay screensharing
  # programs.weylus = on // {
  #   openFirewall = true;
  #   users = [ config._.user ];
  # };

  environment.systemPackages = with pkgs; [
    # polonium # is not working properly
    # (plasma5Packages.polonium.overrideAttrs {
    #   src = pkgs.fetchFromGitHub {
    #     repo = "polonium";
    #     owner = "zeroxoneafour";
    #     rev = "v1.0rc";
    #     sha256 = "sha256-AdMeIUI7ZdctpG/kblGdk1DBy31nDyolPVcTvLEHnNs=";
    #   };
    # })
  ];

  users.groups.sambashare = { };
  users.users."${config._.user}".extraGroups = [ "sambashare" ];

  services.samba = on // {
    openFirewall = true;
    nsswins = true;
    # Some stuff copied over from KDE Neon just to be sure
    extraConfig = ''
      server string = %s (Samba, NixOS)
      passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
      server role = standalone server
      security = user
      encrypt passwords = true
      map to guest = bad user
      usershare max shares = 100
      usershare allow guests = yes
    '';
  };

  services.samba-wsdd = on // {
    discovery = true;
    openFirewall = true;
  };

  services.desktopManager.plasma6 = on;
  services.displayManager = on // {
      sddm = on // {
        wayland = on;
      };
      autoLogin = on // { user = config._.user; };
    # defaultSession = "plasmawayland";
  };

}
