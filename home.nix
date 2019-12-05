args @ { config, pkgs, lib, ... }:

let
  enableThings = with builtins;
    things: overrides:
    if length things == 0
    then overrides
    else pkgs.lib.recursiveUpdate (enableThings (tail things) overrides) {
      "${head things}".enable = true;
    };
  firefoxProfileIcon = { name }: with pkgs;
    # Desktop entries
    makeDesktopItem {
      name = "firefox-${name}";
      desktopName = "Firefox: ${name}";
      exec = "firefox -p ${name}";
      comment = "Opens '${name}' Firefox profile";
    };
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { inherit pkgs; };
in
{

  imports = [ ./secret/home.nix ./i3-config.nix ];

  manual.json.enable = true;

  home = {

    packages = with pkgs; [
      # Interweebs
      firefox tdesktop transmission-gtk

      # Coding stuff
      vscodium jetbrains.idea-community

      # Building stuff
      stack
      jdk8
      elmPackages.elm
      elmPackages.elm-format
      elmPackages.elm-test

      # Emacs is a whiny banana
      #TODO: move into emacs path
      nodePackages.tern # please stop whining spacemacs i'll get you a pony
      ispell

      # Editing
      libreoffice inkscape gimp krita
      cura blender

      # Window manager and looks stuff
      arandr rofi xsecurelock
      redshift compton xautolock
      source-code-pro noto-fonts
      fira-code rofi-pass
      nitrogen

      # Utilities
      alacritty zsh findutils
      pulsemixer docker-compose
      xclip nyx ag fff

      # Viewers
      feh fzf vlc zathura

      # Funny utilities
      aircrack-ng hashcat wireshark

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
      echo '$emacs/bin/emacsclient -s /tmp/emacs1000/server -t $@' >> $out/bin/emacsclient-t
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
      (firefoxProfileIcon { name = "Work"; })

    ];

    file = {
      # Just making sure they don't get collected
      ".cache/direnv_deps".source = (import ~/.direnv-packages.nix);

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

  programs = enableThings [
    "ssh"
    "browserpass"
    "firefox"
    "rofi"
    "alacritty"
    "direnv"
    "fzf"
    "starship"
    "zsh"
    "emacs"
    "git"
    "home-manager"
  ] {

    # == SSH
    ssh = {
      compression = true;
      serverAliveInterval = 5;
    };

    # == Pass and stuff
    browserpass.browsers = [ "firefox" ];

    firefox.extensions = with nur.repos.rycee.firefox-addons; [
      vim-vixen
    ];

    # == Rofi menu
    rofi.theme = "sidebar";

    # == Alacritty terminal
    alacritty = {
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

    direnv.enableZshIntegration = true;

    # Fuzzy file search (Ctrl-T for files; Alt-C for dirs)
    fzf = {
      enableZshIntegration = true;
      fileWidgetCommand = "locate -d ~/.locate.db .";
    };

    starship = {
      enableZshIntegration = true;
      settings = {
        character.symbol = "λ";
        battery = {
          display = [
            {style = "dim green"; threshold = 101;}
          ];
        };
      };
    };

    # == Oh My Zsh!
    zsh = {
      enableCompletion = true;
      enableAutosuggestions = true;
      defaultKeymap = "emacs";
      initExtra = ''
      zstyle ':completion:*' menu select
      '';
      shellAliases = {
        ec = "emacsclient -s /tmp/emacs1000/server -nc";
        ls = "ls --color=auto";
        ll = "ls -hal";
        l = "ll";
      };
      history = {
        size = 100000;
        save = 100000;
        share = true;
      };

    };

    # == Emacs
    emacs = {
      # package = pkgs.emacs;
      # Some packages for Spacemacs it fails to install
      extraPackages = s: with s; [
        spinner undo-tree adaptive-wrap mmm-mode
        tern lsp-mode lsp-haskell
        direnv
      ];
    };

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
