{
  pkgs,
  extraThemes ? {},
  extraScripts ? {},
}:
with builtins;
let
  enabled_modules = [
    "alacritty"
    "doom-emacs"
    "vscodium"
    "vscode"
    "gtk3"
    "sway"
  ];

  themes = {

    dark = rec {
      alacritty = ./alacritty/monokai.yaml;
      spacemacs = "spacemacs-dark";
      doom-emacs = "doom-monokai-classic";
      vscodium = "Monokai";
      vscode = vscodium;
      gtk3 = "Adwaita-dark";
      sway = "";
    };

    light = rec {
      alacritty = ./alacritty/gruvbox-light.yaml;
      spacemacs = "spacemacs-light";
      doom-emacs = "doom-gruvbox-light";
      vscodium = "Default Light+";
      vscode = vscodium;
      gtk3 = "Adwaita";
      sway = "";
    };

    fairy = rec {
      alacritty = ./alacritty/fairyfloss.yaml;
      spacemacs = "spacemacs-light";
      doom-emacs = "doom-fairy-floss";
      vscodium = "fairyfloss";
      vscode = vscodium;
      gtk3 = "Adwaita-dark";
      sway = ''
        sway font pango:FiraSansCondensed 8

        sway bar bar-0 colors background 5a5475
        sway bar bar-0 colors statusline f8f8f0
        sway bar bar-0 colors focused_workspace 554357 554357 f8f8f0
        sway bar bar-0 colors inactive_workspace 343145 343145 f8f8f033

        sway client.unfocused 5a5475aa 5a5475 f8f8f2 5a5475 5a5475
        sway client.focused 5a5475 5a5475 f8f8f2 2e9ef4 28aa77

        sway bar bar-0 font pango:FiraSansCondensed 8
      '';
    };

    fancy = rec {
      alacritty = ./alacritty/gruvbox-light.yaml;
      # spacemacs = "spacemacs-light";
      doom-emacs = "doom-outrun-electric";
      vscodium = "Default Light+";
      vscode = vscodium;
      gtk3 = "Adwaita";
    };
  };
  inlineJq = fname: query: (''
      tmp_settings=$(mktemp)
      cp ${fname} ${fname}.bkp
      ${pkgs.jq}/bin/jq '${query}' ${fname} > $tmp_settings
      mv $tmp_settings ${fname}
  '');
  scripts = {

    # alacritty doesn't create it's config folder by default, so yeah.
    alacritty = (t: ''mkdir -p ~/.config/alacritty; chmod +w ~/.config/alacritty/alacritty.yml; cp ${t} ~/.config/alacritty/alacritty.yml'');

    spacemacs = (t: ''emacsclient -e "(spacemacs/load-theme '${t})"'');

    doom-emacs = (t: ''emacsclient -e "(load-theme '${t} t)"'');

    vscodium = t: inlineJq "~/.config/VSCodium/User/settings.json" ''.["workbench.colorTheme"]=${builtins.toJSON t}'';

    vscode = t: inlineJq "~/.config/Code/User/settings.json" ''.["workbench.colorTheme"]=${builtins.toJSON t}'';

    gtk3 = t: ''${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme \"${t}\"'';

    sway = t: t;
  };

  genSwitcher =
    theme-name: theme:
    ''
    #   #######
    ## ${theme-name}
    ### #######
    fail() { echo failed at setting $prog; }
    setup() { prog=$1; set -e; trap fail EXIT; }
    success() { trap - EXIT; }
    '' +
    concatStringsSep "" (
      attrValues (
        mapAttrs
          (program: theme-fn:
            if !(elem program enabled_modules)
            then ""
            else ''
              { # ${program}
                setup ${program}
                ${theme-fn theme.${program}}
                success
              } &
            '')
          scripts
      )
    );
in pkgs.symlinkJoin {
  name = "theme-switchers";
  paths = attrValues (mapAttrs (
    theme-name: theme:
    pkgs.writeShellScriptBin
      "${theme-name}-theme"
      (genSwitcher theme-name theme)
  ) themes);
}
