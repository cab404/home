args@{ sysconfig, config, pkgs # inputs.nixpkgs
, lib # inputs.nixpkgs.lib
, inputs, prelude, ... }:
with prelude; let __findFile = prelude.__findFile; in {

  imports = [
    <modules/home-manager/user-shell.nix>
  ];

  # Docs for lsp-s
  manual.json.enable = true;

  home = {
    pointerCursor = {
      size = 24;
      package = pkgs.gnome-themes-extra;
      name = "Adwaita";
      gtk = on;
    };

    packages = [

        (pkgs.callPackage <theme-changer.nix> { })

    ];

    # == Keyboard config
    keyboard = {
      layout = sysconfig.services.xserver.xkb.layout;
      options = with builtins;
        filter isString (split "," sysconfig.services.xserver.xkb.options);
    };

    sessionVariables = {
      XCOMPOSEFILE = "${config.xdg.configHome}/XCompose";
      XKB_DEFAULT_LAYOUT = config.home.keyboard.layout;
      XKB_DEFAULT_OPTIONS =
        pkgs.lib.concatStringsSep "," config.home.keyboard.options;
    };

  };

  programs = enableThings [
    "ssh"
    "browserpass"
    "firefox"
    "password-store"
    "alacritty"
  ] {

  };


  xdg = on // {

    configFile = let
      composeConfig = ''
        include "${pkgs.xorg.libX11}/share/X11/locale/en_US.UTF-8/Compose"
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
    
    userDirs = on // {
      music = "$HOME/media/music";
      pictures = "$HOME/media/pictures";
      videos = "$HOME/media/videos";
    };
  
  };

}