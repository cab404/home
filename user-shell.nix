args @ { config, pkgs, lib, ... }:
with import ./lib.nix args;
{
  programs = enableThings [
    "git"
    "direnv"
    "fzf"
    "starship"
    "zsh"
  ] {

    direnv.enableZshIntegration = true;

    # Fuzzy file search (Ctrl-T for files; Alt-C for dirs)
    fzf = {
      enableZshIntegration = true;
      fileWidgetCommand =
        let
          ultimacate = pkgs.writeScriptBin "ultimacate" ''
            #!/usr/bin/env bash
            locate . $@
            locate -d ~/.locate.db . $@
          '';
        in
          "${ultimacate}";
    };

    starship = {
      enableZshIntegration = true;
      settings = {
        character.symbol = "λ";
        battery = {
          display = [
            {style = "dim green"; threshold = 101;}
          ];
        };
      };
    };

    zsh = {
      enableCompletion = true;
      enableAutosuggestions = true;
      defaultKeymap = "emacs";
      initExtra = ''
      zstyle ':completion:*' menu select
      export PATH=$PATH:~/.cargo/bin
      '';
      shellAliases = {
        ec = "emacsclient -s /tmp/emacs1000/server -nc";
        ls = "ls --color=auto";
        ll = "ls -hal";
        l = "ll";
      };
      history = {
        extended = true;
        ignoreDups = true;
        size = 100000;
        save = 100000;
        share = true;
      };

    };

  };

}
