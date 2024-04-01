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
  ]) ++ (with pkgs.plasma5Packages; [
    # I have no clue, why akonadi can't find its plugins with a basic packaging,
    # but merkuro manages to launch it correctly. Something to take a look in nixpkgs.
    merkuro
    akonadi-calendar-tools
    akonadi
    kontact

    polonium
  ]);

  programs.kdeconnect.enable = true;

  # yaaay screensharing
  programs.weylus = on // {
    openFirewall = true;
    users = [ config._.user ];
  };
  # environment.pathsToLink = [];

  environment.systemPackages = with pkgs; [ 
    # plasma5Packages.polonium // is not working properly
    (plasma5Packages.bismuth.overrideAttrs {
      src = pkgs.fetchFromGitHub {
        repo = "bismuth";
        owner = "jkcdarunday";
        rev = "ce377a33232b7eac80e7d99cb795962a057643ae";
        sha256 = "VIOgZGyZYU5CSPTc7HSgGTsimY5dJzf1lTSK+e9fmaA=";
      };
    })
  ];

  services.samba = on // {
    openFirewall = true;
    nsswins = true;
    extraConfig = ''
      map to guest = bad user
      guest account = nobody
      usershare path = /var/lib/samba/usershares
      usershare max shares = 100
      usershare allow guests = yes
      usershare owner only = yes
    '';
  };

  services.samba-wsdd = on // {
    discovery = true;
    openFirewall = true;
  };

  services.desktopManager.plasma6 = on;
  services.xserver = on // {  
    displayManager = {
      sddm = on // {
        wayland = on;
      };
      autoLogin = on // { user = config._.user; };
    # defaultSession = "plasmawayland";
    };
  };

}
