args @ { config, pkgs, lib, ... }:

let
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { inherit pkgs; };
in
{

  imports = [ ./userconf.nix ];

  home = {

    packages = with pkgs; [
      # Interweebs
      firefox tdesktop

      # Coding stuff
      vscodium

      # Editing
      libreoffice inkscape gimp krita
      cura blender

      # Window manager and looks stuff
      arandr rofi xsecurelock
      redshift compton xautolock
      source-code-pro noto-fonts

      # Utilities
      alacritty zsh zathura
      pulsemixer docker-compose
      feh fzf findutils

      # Personal data and sync
      pass browserpass keybase
      gnupg nextcloud-client
      kdeFrameworks.kwallet
      kwalletmanager
    ];

    file = {
      ".spacemacs".source = ./spacemacs.el;
    };
    
    # == Keyboard config
    keyboard = {
      layout = "us,ru";
      options = [ "ctrl:nocaps" "grp:switch" "compose:prsc" ];
    };

  };

  programs = {

    # == SSH
    ssh = {
      compression = true;
      enable = true;
    };

    # == Pass and stuff
    browserpass = {
      enable = true;
      browsers = [ "firefox" ];
    };

    firefox = {
      enable = true;
      extensions = with nur.repos.rycee.firefox-addons; [
        vim-vixen
      ];
    };

    # == Rofi menu
    rofi = {
      enable = true;
      theme = "sidebar";
    };

    # == Alacritty terminal
    alacritty = {
      enable = true;
      settings =
        {
          "env" = {
            "TERM" = "xterm-256color";
          };
          "window" = {
            "gtk-theme-variant" = "dark";
            "decorations" = "none";
          };
          "font" = let family = "Source Code Pro"; in {
            "normal" = { "family" = family; };
            "italic" = { "family" = family; };
            "bold" = { "family" = family; };
            "bold_italic" = { "family" = family; };
            "size" = 6;
          };
        };
    };

    # Fuzzy file search (Ctrl-T for files; Alt-C for dirs)
    fzf = {
      enable = true;
      fileWidgetCommand = "locate -d ~/.locate. .";
      enableZshIntegration = true;
    };

    # == Oh My Zsh!
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git" "systemd"
          "adb" "rsync"
          "docker"
        ];
        theme = "ys";
      };
    };

    # == Emacs
    emacs = {
      enable = true;
      # Some packages for Spacemacs it fails to install
      extraPackages = s: with s; [ spinner undo-tree adaptive-wrap mmm-mode ];
    };

    git.enable = true;
    home-manager.enable = true;
  };

  services = {

    # == Compton window compositor
    compton = {
      enable = true;
      blur = true;
      fade = true;
      shadow = true;
      fadeDelta = 5;
      inactiveOpacity = "0.8";
    };

    # == Redshift
    redshift = {
      enable = true;
      tray = true;
      provider = "manual";
      latitude = "55";
      longitude = "34";
    };

    # == Screen lock
    screen-locker = {
      enable = true;
      lockCmd = "xsecurelock";
      xautolockExtraOptions = [
        "-lockaftersleep"
        "-detectsleep"
      ];
    };

    gpg-agent.enable = true;
    emacs.enable = true;
    nextcloud-client.enable = true;
    keybase.enable = true;
    kbfs.enable = true;

  systemd.user = {
    services.home-locatedb = {
      Service.Environment = "PATH=$PATH:${pkgs.gnused}/bin:${pkgs.coreutils}/bin";
        Unit.Description = "Local locatedb update for fzf";
        Service.ExecStart = "${pkgs.findutils}/bin/updatedb --localpaths='/home/cab' --output=.locate.db";
      };
    timers.home-locatedb = {
      Unit.Description = "Local file DB updates";
      Unit.PartOf="home-locatedb.service";
      Timer.OnUnitActiveSec = "1d";
      Timer.OnBootSec = "15min";
      Install.WantedBy = [ "timers.target" ];
    };
  };

  # == Gnome hates when there's no dconf -.-
  dconf.enable = true;

  # == Gtk and Qt
  gtk = {
    enable = true;
    iconTheme.package = pkgs.paper-icon-theme;
    iconTheme.name = "Paper";
    theme.package = pkgs.adapta-gtk-theme;
    theme.name = "Adapta-Nokto-Eta";
  };
  qt = { enable = true; platformTheme = "gtk"; };

  # == Xsession
  xsession = {
    enable = true;
    windowManager = {
      i3.enable = true;
      i3.package = pkgs.i3-gaps;
      i3.config = import ./i3-config.nix args;
    };
  };

}
