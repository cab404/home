args @ { config, pkgs, lib, ... }:
with import ./lib.nix args;
let
  isWL = true;
in
{

  imports = [
    ./secret/home.nix
    ./modules/home-manager/user-shell.nix
    ./modules/sway/home.nix
  ];

  manual.json.enable = true;

  home = {

    packages = with pkgs; [

      # Interweebs
      transmission-gtk
      thunderbird

      tdesktop
    ] ++ (if isWL then [
      # wayland interweebs
      element-desktop-wayland
    ] else [
      # xserver interweebs
      element-desktop
    ]) ++ [

      # Coding
      #vscodium #imdone #yolo #sorryrms
      (writeShellScriptBin "codium" ''
        ${vscodium}/bin/codium $@ --enable-features=UseOzonePlatform --ozone-platform=wayland
      '')
      rnix-lsp
      gh ghc jdk8 nim
      julia-stable-bin # all julias are generally broken. which strangely coinsides with my life experience

      # Emacs is a whiny banana
      #TODO: move into emacs path
      nodePackages.tern # please stop whining spacemacs i'll get you a pony
      ispell

      # Editing
      libreoffice inkscape gimp krita
      ffmpeg-full peek
      audacity bat

      # Fonts
      source-code-pro noto-fonts
      roboto fira-code fira
      font-awesome-ttf

      # Window manager and looks stuff
      qrencode

      # Command line comfort
      alacritty zsh findutils
      pulsemixer ag fff xclip
      fzf file tree jq

      # Runners
      appimage-run lutris-free

      # Development
      docker-compose insomnia

      minicom pulseview cutecom picocom scrcpy

      # Viewers
      feh vlc zathura ark font-manager baobab evince gthumb
      audacious

      # Funny utilities
      aircrack-ng netsniff-ng hashcat wireshark
      # metasploit
      mtr btfs strace

      # Personal data and sync
      browserpass gnupg nextcloud-client

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
      sudo cp -r ~/data/cab-home/* /etc/nixos
      sudo nixos-rebuild --flake /etc/nixos#''${HOST} $@
      '')

      (pkgs.callPackage ./theme-changer.nix {})

      (writeShellScriptBin "nix-search" ''
      nix search --override-flake nixpkgs ${pkgs.path} --offline nixpkgs $@
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

    file.".mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/lib/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json";
    file.".XCompose".text = ''
    include "${pkgs.xlibs.libX11}/share/X11/locale/en_US.UTF-8/Compose"
    <Multi_key> <period> <backslash>           : "λ"   U03BB  # GREEK SMALL LETTER LAMBDA
    '';

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
    "password-store"
    "alacritty"
    "emacs"
  ] {

    password-store = {
      package = pkgs.pass.withExtensions (e: with e; [
        pass-otp pass-update pass-genphrase pass-audit
      ]);
    };

    # == SSH
    ssh = {
      compression = true;
    };

    # == Pass and stuff
    browserpass.browsers = [ "firefox" ];

    # == Rofi menu
    rofi = {
      theme = "sidebar";
      pass = {
        enable = true;
        extraConfig = ''
        edit_new_pass=false
        notify=true;
        password_length=6
        _pwgen () {
          ${pkgs.xkcdpass}/bin/xkcdpass -w eff-special -d - -n $1
        }
        '';
      };
    };

    # == Emacs
    emacs = {
      package = pkgs.emacs.override {
        imagemagick = pkgs.imagemagickBig;
      };
      # Some packages for Spacemacs it fails to install
      extraPackages = s: with s; [
        adaptive-wrap mmm-mode tern
        direnv ag
      ];
    };

  };

  services = enableThings [
    "emacs"
    "gpg-agent"
    "kbfs"
    "keybase"
    "pass-secret-service"
    "password-store-sync"
    "flameshot"
    "easyeffects"
    "kdeconnect"
  ] { };

  # == Gnome hates when there's no dconf -.-
  dconf.enable = true;

}
