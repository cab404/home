args@{ sysconfig, config, pkgs # inputs.nixpkgs
, lib # inputs.nixpkgs.lib
, inputs, prelude, ... }:
with prelude; let __findFile = prelude.__findFile; in {

  # Docs for lsp-s
  manual.json.enable = true;

  home = {
    # pointerCursor = {
    #   size = 24;
    #   package = pkgs.gnome-themes-extra;
    #   name = "Adwaita";
    #   gtk = on;
    # };

    packages = [
        (pkgs.callPackage <theme-changer.nix> { })
    ];

    # == Keyboard config
    # keyboard = {
    #   layout = sysconfig.services.xserver.xkb.layout;
    #   options = with builtins;
    #     filter isString (split "," sysconfig.services.xserver.xkb.options);
    # };

    # sessionVariables = {
    #   XCOMPOSEFILE = "${config.xdg.configHome}/XCompose";
    #   XKB_DEFAULT_LAYOUT = config.home.keyboard.layout;
    #   XKB_DEFAULT_OPTIONS =
    #     pkgs.lib.concatStringsSep "," config.home.keyboard.options;
    # };
  };

  programs = enableThings [
    "ssh"
    "browserpass"
    # "firefox"
    "password-store"
    "alacritty"
  ] {

  };


  xdg = on // {

    configFile = let
      composeConfig = ''
        include "${pkgs.libx11}/share/X11/locale/en_US.UTF-8/Compose"
        <Multi_key> <period> <backslash>           : "λ"  U03BB  # GREEK SMALL LETTER LAMBDA
        <Multi_key> <l> <a>                        : "λ"  U03BB  # GREEK SMALL LETTER LAMBDA
        <Multi_key> <L> <a>                        : "Λ"  U039B  # GREEK CAPITAL LETTER LAMBDA
        <Multi_key> <r> <o>                        : "ρ"  U03C1  # GREEK SMALL LETTER RHO
        <Multi_key> <R> <o>                        : "Ρ"  U03A1  # GREEK CAPITAL LETTER RHO
        <Multi_key> <p> <i>                        : "π"  U03C0  # GREEK SMALL LETTER PI
        <Multi_key> <P> <i>                        : "Π"  U03A0  # GREEK CAPITAL LETTER PI
        <Multi_key> <e> <t>                        : "ε"  U03B5  # GREEK SMALL LETTER EPSILON
        <Multi_key> <E> <t>                        : "Ε"  U0395  # GREEK CAPITAL LETTER EPSILON
        <Multi_key> <a> <l>                        : "α"  U03B1  # GREEK SMALL LETTER ALPHA
        <Multi_key> <A> <L>                        : "Α"  U0391  # GREEK CAPITAL LETTER ALPHA
        <Multi_key> <s> <i>                        : "σ"  U03C3  # GREEK SMALL LETTER SIGMA
        <Multi_key> <S> <i>                        : "Σ"  U03A3  # GREEK CAPITAL LETTER SIGMA
        <Multi_key> <d> <e>                        : "δ"  U03B4  # GREET SMALL LETTER DELTA
        <Multi_key> <D> <e>                        : "Δ"  U0394  # GREEK CAPITAL LETTER DELTA
        <Multi_key> <t> <h>                        : "θ"  U03B8  # GREEK SMALL LETTER THETA
        <Multi_key> <T> <h>                        : "Θ"  U0398  # GREEK CAPITAL LETTER THETA
        <Multi_key> <o> <m>                        : "ω"  U03C9  # GREEK SMALL LETTER OMEGA
        <Multi_key> <O> <m>                        : "Ω"  U03A9  # GREEK CAPITAL LETTER OMEGA
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
