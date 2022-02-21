{
  pkgs,
  extraThemes ? {},
  extraScripts ? {},
}:
with builtins;
let
  themes = {

    dark = rec {
      alacritty = ./alacritty/monokai.yaml;
      # spacemacs = "spacemacs-dark";
      vscodium = "Monokai";
      vscode = vscodium;
      gtk3 = "Adwaita-dark";
    };

    light = rec {
      alacritty = ./alacritty/gruvbox-light.yaml;
      # spacemacs = "spacemacs-light";
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

    alacritty = (t: ''cp ${t} ~/.config/alacritty/alacritty.yml'');

    # spacemacs = (t: ''emacsclient -e "(spacemacs/load-theme '${t})"'');

    vscodium = t: inlineJq "~/.config/VSCodium/User/settings.json" ''.["workbench.colorTheme"]=${builtins.toJSON t}'';

    vscode = t: inlineJq "~/.config/Code/User/settings.json" ''.["workbench.colorTheme"]=${builtins.toJSON t}'';

    gtk3 = t: ''${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme \"${t}\"'';

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
          (program: theme-fn: ''
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
