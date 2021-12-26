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
      (if isWL then element-desktop-wayland else element-desktop)

      # Coding
      #vscodium #imdone #yolo #sorryrms
      (writeShellScriptBin "codium" ''
        ${vscodium}/bin/codium $@ --enable-features=UseOzonePlatform --ozone-platform=wayland
      '')
      rnix-lsp
      gh ghc jdk8 nim
      julia-stable-bin # all julias are generally broken. which strangely coinsides with my life experience

      # Editing
      libreoffice inkscape gimp krita
      ffmpeg-full peek
      audacity bat
      openscad
      blender
      lmms

      # at least do backups
      restic

      # Fonts
      source-code-pro noto-fonts
      roboto fira-code fira
      font-awesome-ttf

      # Window manager and looks stuff
      helvum
      qrencode

      # Command line comfort
      alacritty zsh findutils
      pulsemixer ag fzf file
      jq ranger btop

      # Runners
      appimage-run lutris-free

      # Development
      docker-compose insomnia

      # Hardware?
      minicom pulseview cutecom picocom scrcpy

      # Viewers
      feh mpv zathura font-manager gthumb audacious

      # Gnome
    ] ++ (with gnome; [
      nautilus
      gnome-disk-utility
      gnome-online-accounts
      gnome-power-manager
      file-roller
      gucharmap
      baobab
      evince
      sushi
    ]) ++ [

      # Funny utilities
      aircrack-ng netsniff-ng hashcat wireshark mtr strace

      # Personal data and sync
      browserpass gnupg nextcloud-client

      # Themes, all of them
      adwaita-qt
      gnome3.adwaita-icon-theme
      gnome-themes-extra

      '')

      # TODO: Make cab-home switch both system and local config from any folder.
      # System reload
      (writeShellScriptBin "cab-home" ''
      set -e
      sudo cp -r ~/data/cab-home/* /etc/nixos
      sudo nixos-rebuild --flake /etc/nixos#''${HOST} $@
      '')

      # like which, but for nix
      (writeShellScriptBin "what" ''
      readlink -f $(which $@)
      '')

      (pkgs.callPackage ./theme-changer.nix {})

      (writeShellScriptBin "nix-search" ''
      nix search --override-flake nixpkgs ${pkgs.path} --offline nixpkgs $@
      '')

    ];

    file.".mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/lib/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json";

    # == Keyboard config
    keyboard = {
      layout = "us,ru";
      options = [ "ctrl:nocaps" "grp:switch" ];
    };

    sessionVariables = {
      EDITOR = "vi";
      XCOMPOSEFILE = "${config.xdg.configHome}/XCompose";
      XKB_DEFAULT_LAYOUT = config.home.keyboard.layout;
      XKB_DEFAULT_OPTIONS = pkgs.lib.concatStringsSep "," config.home.keyboard.options;
    };
  };

  xdg.configFile =
  let composeConfig = ''
      include "${pkgs.xlibs.libX11}/share/X11/locale/en_US.UTF-8/Compose"
      <Multi_key> <period> <backslash>           : "λ"   U03BB  # GREEK SMALL LETTER LAMBDA
    '';
  in {
    # you probably wonder, "how did you find this?"
    # it's obvious: gtk3 sources.
    # also, it won't work in gtk2.
    # and yes, gtk can't XCOMPOSEFILE, even though it's in specification.
    "gtk-3.0/Compose".text = composeConfig;
    # And this one I found in tdesktop. Cause why not? At least it's XDG Compliant (tm)
    "XCompose".text = composeConfig;
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
    "exa"
  ] {

    exa.enableAliases = true;

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
  };

  services = enableThings [
    "gpg-agent"
    "pass-secret-service"
    "password-store-sync"
    "flameshot"
    "easyeffects"
    "kdeconnect"
  ] {};

  # == Gnome hates when there's no dconf -.-
  dconf.enable = true;
  # long time brewing
  xdg.enable = true;

}
