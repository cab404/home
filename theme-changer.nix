{
  pkgs,
  extraThemes ? {},
  extraScripts ? {},
}:
with builtins;
let
  themes = {

    dark = {
      alacritty = ./alacritty/monokai.yaml;
      spacemacs = "spacemacs-dark";
      vscodium = "Monokai";
    };

    light = {
      alacritty = ./alacritty/solarized-light.yaml;
      spacemacs = "spacemacs-light";
      vscodium = "Default Light+";
    };

  };
  scripts = {

    alacritty = (t: ''cp ${t} ~/.config/alacritty/alacritty.yml'');

    spacemacs = (t: ''emacsclient -e "(spacemacs/load-theme '${t})"'');

    vscodium = (t: ''
      vsc_settings=$(mktemp)
      cp ~/.config/VSCodium/User/settings.json ~/.config/backup.vscodium.json
      ${pkgs.jq}/bin/jq '.["workbench.colorTheme"]=${builtins.toJSON t}' ~/.config/VSCodium/User/settings.json > $vsc_settings
      mv $vsc_settings ~/.config/VSCodium/User/settings.json
    '');

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
