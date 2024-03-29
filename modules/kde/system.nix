{ config, pkgs, lib, prelude, ... }: with prelude; let __findFile = prelude.__findFile; in {

   home-manager.users.${config._.user}.imports = [
    ./home.nix
  ];

  imports = [
    ../graphical.nix
  ];

  environment.homeBinInPath = true; # ..?

  environment.defaultPackages = (with pkgs; [
    wl-clipboard # yes, we need it
    wayland-utils
    glxinfo
    vulkan-tools
  ]) ++ (with pkgs.plasma5Packages; [
    # I have no clue, why akonadi can't find its plugins with a basic packaging,
    # but merkuro manages to launch it correctly. Something to take a look in nixpkgs.
    merkuro
    akonadi-calendar-tools
    akonadi
    kontact
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

  services.xserver = on // {  
    desktopManager.plasma5 = on;
    displayManager.sddm = on // {
      wayland = on;
    };
    displayManager.autoLogin = on // { user = config._.user; };
    displayManager.defaultSession = "plasmawayland";
  };

}
