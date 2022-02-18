args @ { sysconfig, config, pkgs /* inputs.nixpkgs */, lib /* inputs.nixpkgs.lib */, ... }:
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
      wofi

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

      (let
        conf = builtins.toFile "woficonf" ''
        filter_rate=200
        dynamic_lines=true
        insensitive=true
        matching=fuzzy
        layer=overlay
        '';
      in (writeShellScriptBin "wofi-pass" ''
      WOFI=${wofi}/bin/wofi
      WCONF="-c ${conf}"
      set -e
      MODE=$(echo -e "\notp" | $WOFI $WCONF --show dmenu)
      SELECTION=$((cd $PASSWORD_STORE_DIR; find -type f -not -path './.*' | sed 's/.gpg$//') | $WOFI $WCONF --show dmenu)
      echo pass --clip $MODE $SELECTION
      pass $MODE -c $SELECTION
      ''))

      # like which, but for nix
      (writeShellScriptBin "what" ''
      readlink -f $(which $@)
      '')

      (pkgs.callPackage ./theme-changer.nix {})

      (writeShellScriptBin "nix-search" ''
      nix search --offline nixpkgs $@
      '')

    ];

    file.".mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/lib/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json";

    # == Keyboard config
    keyboard = {
      layout = sysconfig.services.xserver.layout;
      options = with builtins; filter isString (split "," sysconfig.services.xserver.xkbOptions);
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
