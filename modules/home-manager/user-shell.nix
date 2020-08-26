args @ { config, pkgs, lib, ... }:
with import ../../lib.nix args;
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
    fzf = let
      # locate doesn't search at home, and that would be insecure.
      # so yeah
      ultimacate = pkgs.writeScript "l" ''
            #!/usr/bin/env bash
            locate $@
            locate -d ~/.locate.db $@
          '';
    in {
      enableZshIntegration = true;
      fileWidgetCommand = "${ultimacate} .";
    };

    starship = {
      enableZshIntegration = true;
      settings = {
        character.symbol = "δ";
        battery = {
          display = [
            {style = "red"; threshold = 15;}
            {style = "dimmed red"; threshold = 50;}
            {style = "dimmed green"; threshold = 99;}
            {style = "bold green"; threshold = 100;}
          ];
        };
        # slow af
        haskell.disabled = true;

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
