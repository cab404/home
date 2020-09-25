args @ { config, pkgs, lib, ... }:
with import ./lib.nix args;
{

  imports = [
    ./secret/home.nix
    ./modules/home-manager/user-shell.nix
    ./modules/i3/home.nix
  ];

  manual.json.enable = true;

  home = {

    packages = with pkgs; [

      # Interweebs
      firefox transmission-gtk
      thunderbird

      # Coding stuff
      vscodium

      # Building stuff
      stack
      jdk8 nim

      # Emacs is a whiny banana
      #TODO: move into emacs path
      nodePackages.tern # please stop whining spacemacs i'll get you a pony
      emacsPackages.telega
      ispell

      # Editing
      libreoffice inkscape gimp krita
      joplin-desktop ffmpeg

      # Fonts
      source-code-pro noto-fonts
      roboto fira-code fira
      font-awesome-ttf

      # Window manager and looks stuff
      rofi rofi-pass qrencode

      # Command line comfort
      alacritty zsh findutils
      pulsemixer ag fff xclip
      fzf file tree

      # Runners
      appimage-run lutris-free

      # Development
      docker-compose insomnia

      # Hardware stuff
      androidenv.androidPkgs_9_0.platform-tools
      minicom pulseview cutecom

      # Viewers
      feh vlc zathura ark clementine

      # Funny utilities
      aircrack-ng netsniff-ng hashcat wireshark
      metasploit mtr btfs

      # Personal data and sync
      (pass.withExtensions (e: with e; [
        pass-otp pass-update pass-genphrase pass-audit
      ]))
      browserpass keybase
      gnupg nextcloud-client
      kdeFrameworks.kwallet
      kwalletmanager python3Packages.snapperGUI

      # Blocking emacs.
      (writeShellScriptBin "ee" ''
      ${emacs}/bin/emacsclient -s /tmp/emacs1000/server -c $@
      '')

      # Non-blocking emacs
      (writeShellScriptBin "ec" ''
      ${emacs}/bin/emacsclient -s /tmp/emacs1000/server -nc $@
      '')

      # TODO: Make cab-home switch both system and local config from any folder.
      # System reload
      (writeShellScriptBin "cab-home" ''
      #!/usr/bin/env bash
      sudo cp -r ~/data/cab-home/* /etc/nixos
      sudo nixos-rebuild $@
      '')

      (writeShellScriptBin "nix-search" ''
      nix search ${<nixpkgs>} --no-update-lock-file --no-registries $@
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
      # Just making sure they don't get collected
      # ".cache/direnv_deps".source = (import ~/.direnv-packages.nix);
      ".config/rofi-pass/config".source = ./rofi-menu-config.sh;
    };

    # == Keyboard config
    keyboard = {
      layout = "us,ru";
      options = [ "ctrl:nocaps" "grp:switch" ];
    };

    sessionVariables = {
      EDITOR = "ee";
      XKB_DEFAULT_LAYOUT = "us,ru";
      XKB_DEFAULT_OPTIONS = "ctrl:nocaps,grp:switch";
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
    "emacs"
  ] {

    # == SSH
    ssh = {
      compression = true;
    };

    # == Pass and stuff
    browserpass.browsers = [ "firefox" ];

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
            "size" = 8;
          };
        };
    };

    # == Emacs
    emacs = {
      package = pkgs.emacs.override {
        imagemagick = pkgs.imagemagickBig;
      };
      # Some packages for Spacemacs it fails to install
      extraPackages = s: with s; [
        spinner undo-tree adaptive-wrap mmm-mode
        tern lsp-mode lsp-haskell
        direnv ag
        telega
      ];
    };

  };

  services = enableThings [
    "emacs"
    "gpg-agent"
    "kbfs"
    "keybase"
    "flameshot"
    "lorri"
  ] { };

  systemd.user = {

    # Locatedb for faster fzf completion
    # TODO: try making tracker work

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

  gtk = {
    enable = true;
    iconTheme.package = pkgs.paper-icon-theme;
    iconTheme.name = "Paper";
    theme.package = pkgs.adapta-gtk-theme;
    theme.name = "Adapta-Nokto-Eta";
  };

  qt = { enable = true; platformTheme = "gtk"; };
}
