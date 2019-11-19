args @ { config, pkgs, lib, ... }:

let
  enableThings = with builtins;
    things: overrides:
    if length things == 0
    then overrides
    else pkgs.lib.recursiveUpdate (enableThings (tail things) overrides) {
      "${head things}".enable = true;
    };
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { inherit pkgs; };
in
{

  imports = [ ./userconf.nix ./i3-config.nix ];

  manual.json.enable = true;

  home = {

    packages = with pkgs; [
      # Interweebs
      firefox tdesktop

      # Coding stuff
      vscodium jetbrains.idea-community

      # Building stuff
      stack
      jdk8
      elmPackages.elm
      elmPackages.elm-format
      elmPackages.elm-test

      # Editing
      libreoffice inkscape gimp krita
      cura blender

      # Window manager and looks stuff
      arandr rofi xsecurelock
      redshift compton xautolock
      source-code-pro noto-fonts
      fira-code rofi-pass

      # Utilities
      alacritty zsh findutils
      pulsemixer docker-compose
      xclip nyx ag fff

      # Viewers
      feh fzf vlc zathura

      # Funny utilities
      aircrack-ng hashcat

      # Personal data and sync
      (pass.withExtensions (e: with e; [
        pass-otp pass-update pass-genphrase pass-audit
      ]))
      browserpass keybase
      gnupg nextcloud-client
      kdeFrameworks.kwallet
      kwalletmanager

      # Editor sometimes do not work if contains options.
      (runCommand "emacs-client-t" { inherit emacs; } ''
      mkdir -p $out/bin
      echo '#!/bin/sh' >> $out/bin/emacsclient-t
      echo '${emacs}/bin/emacsclient -t' >> $out/bin/emacsclient-t
      chmod +x $out/bin/emacsclient-t
      '')

      # Desktop entries
      (makeDesktopItem {
        name = "emacsclient";
        desktopName = "Emacs client";
        exec = "emacsclient -c";
        comment = "Text editor";
        icon = builtins.fetchurl {
          url = "http://spacemacs.org/img/logo.svg";
          sha256 = "85700ee004fac81c58fdea353b1fd7c2b3ead2ee630f2988b94eba068e3ec072";
        };
      })

    ];

    file = {
      ".config/rofi-pass/config".source = ./rofi-menu-config.sh;
    };

    # == Keyboard config
    keyboard = {
      layout = "us,ru";
      options = [ "ctrl:nocaps" "grp:switch" "compose:prsc" ];
    };

    sessionVariables = {
      EDITOR = "emacsclient-t";
    };

  };

  # don't know where to put it
  fonts.fontconfig.enable = true;

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
          };
          "font" = let family = "Fira Code"; in {
            "normal" = { "family" = family; };
            "italic" = { "family" = family; };
            "bold" = { "family" = family; };
            "bold_italic" = { "family" = family; };
            "size" = 5;
          };
        };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    # Fuzzy file search (Ctrl-T for files; Alt-C for dirs)
    fzf = {
      enable = true;
      fileWidgetCommand = "locate -d ~/.locate.db .";
      enableZshIntegration = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings.character.symbol = "λ";
    };

    # == Oh My Zsh!
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      history = {
        size = 100000;
        save = 100000;
        share = true;
      };

      # Home manager assumes ohmyzsh loads
      # compinit by itself, but it does not
      enableCompletion = false;
      initExtra = "compinit -C";

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git" "systemd"
          "adb" "rsync"
          "docker"
        ];
      };
    };

    # == Emacs
    emacs = {
      enable = true;
      # Some packages for Spacemacs it fails to install
      extraPackages = s: with s; [
        spinner undo-tree adaptive-wrap mmm-mode
        tern
      ];
    };

    git.enable = true;
    home-manager.enable = true;
  };

  services = enableThings [
    "flameshot"              "gpg-agent"
    "pasystray"              "emacs"
    "blueman-applet"         "nextcloud-client"
    "network-manager-applet" "kbfs"
    "compton"                "redshift"
    "screen-locker"
    # eats too much
    # "keybase"
  ]
    {

    # == Compton window compositor
    compton = {
      blur = true;
      fade = true;
      shadow = true;
      fadeDelta = 5;
      inactiveOpacity = "0.8";
    };

    # == Redshift
    redshift = {
      tray = true;
      provider = "manual";
      latitude = "55";
      longitude = "34";
    };

    # == Screen lock
    screen-locker = {
      lockCmd = "xsecurelock";
      xautolockExtraOptions = [
        "-lockaftersleep"
        "-detectsleep"
      ];
    };

  };

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

}
