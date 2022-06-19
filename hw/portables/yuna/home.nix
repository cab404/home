args @ { sysconfig, config, pkgs /* inputs.nixpkgs */, lib /* inputs.nixpkgs.lib */, inputs, ... }:
with import ../../../lib.nix args;
let
  isWL = true;
in
{

  imports = [
    inputs.nix-doom-emacs.hmModule
    ../../../modules/home-manager/user-shell.nix
    ../../../modules/sway/home.nix
  ];

  manual.json.enable = true;

  home = {

    packages = with pkgs; [

      # Interweebs
      transmission-gtk
      thunderbird
      # jitsi-meet-electron
      tdesktop
      mumble
      ungoogled-chromium

      (if isWL then element-desktop-wayland else element-desktop)

      # Coding
      #vscodium #imdone #yolo #sorryrms
      rnix-lsp
      gh
      ghc
      jdk8
      nim
      julia-stable-bin # all julias are generally broken. which strangely coinsides with my life experience

      # Editing
      libreoffice
      inkscape
      gimp
      krita
      ffmpeg-full
      peek
      audacity
      bat
      openscad
      solvespace
      blender
      simple-scan
      lmms

      # at least do backups
      restic

      # Fonts
      source-code-pro
      noto-fonts
      noto-fonts-cjk
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      roboto
      fira-code
      fira
      font-awesome
      gohufont

      # Window manager and looks stuff
      helvum
      qrencode

      # Command line comfort
      alacritty
      zsh
      findutils
      pulsemixer
      silver-searcher
      fzf
      file
      jq
      jless
      ranger
      btop

      # Runners
      appimage-run
      lutris-free

      # Development
      docker-compose
      insomnia
      remmina

      # Hardware?
      minicom
      pulseview
      cutecom
      picocom
      scrcpy
      qFlipper
      ledger-live-desktop

      # Viewers
      feh
      mpv
      zathura
      font-manager
      gthumb
      audacious
      quodlibet
      ytfzf


    ]
    # Mate
     ++ (with mate; [
      mate-calc
      caja
    ])

    # Gnome
    ++ (with gnome; [
      gnome-disk-utility
      gnome-power-manager
      gnome-sound-recorder
      seahorse
      file-roller
      gucharmap
      baobab
      evince
      sushi
    ]) ++ [
      gnome-online-accounts

      # Funny utilities
      aircrack-ng
      netsniff-ng
      netdiscover
      hashcat
      wireshark
      mtr
      strace
      hcxdumptool

      # Personal data and sync
      browserpass
      gnupg
      nextcloud-client

      # Themes, all of them
      adwaita-qt
      gnome3.adwaita-icon-theme
      gnome-themes-extra

      # Notes are important!
      (writeShellScriptBin "notes" ''
        codium ~/data/cab/notes/ ~/data/cab/notes/$(date +%Y-%m-%d).md
      '')

      (
        let
          conf = builtins.toFile "woficonf" ''
            filter_rate=200
            dynamic_lines=true
            insensitive=true
            matching=fuzzy
            layer=overlay
          '';
        in
        (writeShellScriptBin "wofi-pass" ''
          WOFI=${wofi}/bin/wofi
          WCONF="-c ${conf}"
          set -e
          MODE=$(echo -e "\notp" | $WOFI $WCONF --show dmenu)
          SELECTION=$((cd $PASSWORD_STORE_DIR; find -type f -not -path './.*' | sed 's/.gpg$//') | $WOFI $WCONF --show dmenu)
          echo pass --clip $MODE $SELECTION
          pass $MODE -c $SELECTION
        '')
      )

      # like which, but for nix
      (writeShellScriptBin "what" ''
        readlink -f $(which $@)
      '')

      (pkgs.callPackage ../../../theme-changer.nix { })

      (writeShellScriptBin "nix-search" ''
        nix search --offline nixpkgs $@
      '')

      # Blocking emacs.
      (writeShellScriptBin "ee" ''
        ${emacs}/bin/emacsclient -c $@
      '')

      # Non-blocking emacs
      (writeShellScriptBin "ec" ''
        ${emacs}/bin/emacsclient -nc $@
      '')

    ];

    file.".mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/lib/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json";

    # == Keyboard config
    keyboard = {
      layout = sysconfig.services.xserver.layout;
      options = with builtins; filter isString (split "," sysconfig.services.xserver.xkbOptions);
    };

    sessionVariables = {
      XCOMPOSEFILE = "${config.xdg.configHome}/XCompose";
      XKB_DEFAULT_LAYOUT = config.home.keyboard.layout;
      XKB_DEFAULT_OPTIONS = pkgs.lib.concatStringsSep "," config.home.keyboard.options;
    };
  };

  xdg.configFile =
    let composeConfig = ''
      include "${pkgs.xorg.libX11}/share/X11/locale/en_US.UTF-8/Compose"
      <Multi_key> <period> <backslash>           : "λ"   U03BB  # GREEK SMALL LETTER LAMBDA
    '';
    in
    {
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
    "bat"
    "doom-emacs"
  ]
    {

      doom-emacs = {
        doomPrivateDir = ../../../doom.d;
      };

      vscode = on // {
        package = pkgs.vscodium;
        # (writeShellScriptBin "codium" ''
        #   ${vscodium}/bin/codium $@ # --enable-features=UseOzonePlatform --ozone-platform=wayland
        # '')
      };

      firefox.package = pkgs.firefox-esr-unwrapped;

      exa.enableAliases = true;

      password-store = {
        package = pkgs.pass.withExtensions (e: with e; [
          pass-otp
          pass-update
          pass-genphrase
          pass-audit
        ]);
      };

      # == SSH
      ssh = {
        compression = true;
        matchBlocks =
          let
            is = (user: identityFile: { inherit user identityFile; });
          in
          {
            "*.serokell.team" = {
              port = 17788;
              user = "cab404";
            };

            "cab404.ru" = is "cab" "~/.ssh/id_rsa";
          };
      };

      # == Pass and stuff
      browserpass.browsers = [ "firefox" ];

      git = {
        userName = "Vladimir Serov";
        userEmail = "me@cab404.ru";
        extraConfig = {
          pull.ff = "only";
          init = {
            defaultBranch = "master";
          };
        };
        signing = {
          key = "1BB96810926F4E715DEF567E6BA7C26C3FDF7BB3";
          signByDefault = true;
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
    # "emacs"
  ]
    {
      gpg-agent = {
        enableSshSupport = true;
        sshKeys = [
          "28D5BB057E5E743B9917335CDA8F71D89506FF7F"
          "AB76EEA25B5E957595B61C28F5A81F597C44A711"
        ];
      };
    };

  # == Gnome hates when there's no dconf -.-
  dconf.enable = true;
  # long time brewing
  xdg.enable = true;

}
