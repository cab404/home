args@{ sysconfig
, config
, pkgs # inputs.nixpkgs
, lib # inputs.nixpkgs.lib
, inputs
, prelude
, ...
}:
with prelude; let __findFile = prelude.__findFile; in
let isWL = true;
in
{

  home = {

    packages = with pkgs;
      [

        speechd
        # wine
        # winetricks

        # Interweebs
        transmission_4-qt
        thunderbird
        nheko

        # Coding/Netutils
        gh
        glab

        # Coding
        nil
        ghc
        sbcl
        jdk17
        nim
        # julia-stable-bin # all julias are generally broken. which strangely coinsides with my life experience

        # Editing
        libreoffice
        inkscape
        gimp
        krita
        ffmpeg-full
        # peek # Doesn't support wayland :(
        tenacity
        openscad-unstable
        solvespace
        blender
        simple-scan
        # lmms

        # at least do backups
        restic

        # Fonts
        source-code-pro
        noto-fonts
        fira-code
        fira
        font-awesome
        gohufont
        source-code-pro
        source-sans
        ubuntu_font_family

        # Window manager and looks stuff
        # helvum
        qpwgraph
        pavucontrol
        qrencode


        # Command line comfort
        # alacritty
        zellij
        perl
        zsh

        pulsemixer
        silver-searcher # some scripts still use it
        fzf
        file
        bat
        jq
        jless
        ranger
        btop

        nix-prefetch-github

        # Runners
        appimage-run
        lutris-free

        # Development
        zed-editor
        docker-compose
        # insomnia
        remmina
        patchelf

        # Hardware?
        pulseview
        minicom
        cutecom
        picocom
        scrcpy
        # qFlipper
        headphones-toolbox
        android-tools
        #ledger-live-desktop

        # Viewers
        fstl
        feh
        mpv
        zathura
        font-manager
        # gthumb
        audacious
        ytfzf
        yt-dlp
        unrar-free

        # Funny utilities
        aircrack-ng
        netsniff-ng
        netdiscover
        hashcat
        wireshark
        mtr
        strace
        hcxdumptool
        sshfs

        # KDE Connect only passes thru user profile
        # systemd

        # Personal data and sync
        # anytype # too old
        browserpass
        gnupg
        nextcloud-client # meh

        # Themes, all of them
        adwaita-qt
        adwaita-icon-theme
        gnome-themes-extra

        # Notes are important!
        (writeShellScriptBin "notes" ''
          # codium ~/data/cab/notes/ ~/data/cab/notes/$(date +%Y-%m-%d).md
          flatpak run --socket=wayland com.logseq.Logseq --enable-features=UseOzonePlatform --ozone-platform=wayland
        '')

        # Runs something with common libs
        (writeShellScriptBin "with-libs" ''
          export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${ lib.makeLibraryPath (with pkgs; [
            libsecret
            openssl

            fontconfig
            gdk-pixbuf
            glamoroustoolkit
            gst_all_1.gst-plugins-base
            gst_all_1.gstreamer
            qt6.full
            saw-tools

            webkitgtk
            xorg.libX11
            zlib
          ]) }
          exec $@
        '')

        (pkgs.callPackage <theme-changer.nix> { })

      ];

  };
  fonts.fontconfig.enable = false;

  home.sessionVariables = {
    # Grrr, no proper way to do that
    GNUPGHOME = config.programs.gpg.homedir;
  };

  programs = enableThings [
    "git"
    "ssh"
    "browserpass"
    "firefox"
    "password-store"
    "alacritty"
    "chromium"
  ]
    {

      gpg.homedir = "${config.xdg.dataHome}/gnupg";

      # so degoogled spotify doesn't work
      chromium = {
        package = pkgs.ungoogled-chromium;
        commandLineArgs = [
          "--enable-logging=stderr"
        ];
      };

      vscode = on // { package = pkgs.vscodium; };


      password-store = {
        package = pkgs.pass.withExtensions
          (e: with e; [ pass-otp pass-update pass-genphrase ]);
      };

      # == SSH
      ssh = {
        compression = true;
        controlMaster = "auto";
        controlPersist = "2m";
        matchBlocks =
          let is = (user: identityFile: { inherit user identityFile; });
          in
          {
            # "cab404.ru" = is "cab" "~/.ssh/id_rsa";
          };
      };

      # == Pass and stuff
      browserpass.browsers = [ "firefox" ];

      git = {
        userName = "Cabia Rangris";
        userEmail = "cab@cab.moe";
        extraConfig = {
          pull.ff = "only";
          init = { defaultBranch = "master"; };
        };
        signing = {
          key = "1BB96810926F4E715DEF567E6BA7C26C3FDF7BB3";
          signByDefault = true;
        };
      };
    };

  services = enableThings [
    # "flameshot"
  ]
    {

      gpg-agent = on // {
        enableSshSupport = true;
        sshKeys = [
          "28D5BB057E5E743B9917335CDA8F71D89506FF7F"
          "AB76EEA25B5E957595B61C28F5A81F597C44A711"
        ];
      };

      git-sync = on // {
        repositories = {
          pass = {
            path = config.programs.password-store.settings.PASSWORD_STORE_DIR;
            uri = "git@git.sr.ht:~cab/pwds";
          };
          notes = {
            path = "/home/cab/data/cab/notes";
            uri = "git@git.sr.ht:~cab/notes";
            interval = 120;
          };
        };
      };

    };


}
