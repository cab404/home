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
      transmission-gtk
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
      joplin-desktop ffmpeg peek

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
      minicom pulseview cutecom picocom scrcpy

      # Viewers
      feh vlc zathura ark clementine font-manager baobab

      # Funny utilities
      aircrack-ng netsniff-ng hashcat wireshark
      metasploit mtr btfs strace

      # Personal data and sync
      (pass.withExtensions (e: with e; [
        pass-otp pass-update pass-genphrase pass-audit
      ]))
      browserpass keybase
      gnupg nextcloud-client

      # Themes, all of them
      adwaita-qt
      gnome3.adwaita-icon-theme
      gnome-themes-extra
      theme-obsidian2
      adapta-gtk-theme
      adapta-kde-theme

      # Blocking emacs.
      (writeShellScriptBin "ee" ''
      ${emacs}/bin/emacsclient -c $@
      '')

      # Non-blocking emacs
      (writeShellScriptBin "ec" ''
      ${emacs}/bin/emacsclient -nc $@
      '')

      # TODO: Make cab-home switch both system and local config from any folder.
      # System reload
      (writeShellScriptBin "cab-home" ''
      #!/usr/bin/env bash
      sudo cp -r ~/data/cab-home/* /etc/nixos
      sudo nixos-rebuild --flake /etc/nixos#''${HOST} $@
      '')

      (writeShellScriptBin "nix-search" ''
      nix search ${pkgs.path} --no-update-lock-file --no-registries $@
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
    # "kbfs"
    # "keybase"
    "flameshot"
    # "lorri"
  ] { };

  # == Gnome hates when there's no dconf -.-
  dconf.enable = true;

  gtk = {
    enable = true;
    iconTheme.package = pkgs.gnome3.adwaita-icon-theme;
    iconTheme.name = "Adwaita";
    gtk2.extraConfig = ''
    gtk-enable-animations=1
    gtk-primary-button-warps-slider=0
    gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
    gtk-menu-images=1
    gtk-button-images=1
    gtk-font-name="Noto Sans,  10"
    '';
    theme.package = pkgs.adapta-gtk-theme;
    theme.name = "Adapta-Nokto-Eta";
  };

}
