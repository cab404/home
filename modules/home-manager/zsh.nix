args @ { sysconfig, config, pkgs, lib, ... }:
with import ../../lib.nix args;
{
  home.shell.enableZshIntegration = true;

  programs.bat = on;

  # Nushell doesn't need a better ls
  programs.eza = on // {
    enableNushellIntegration = false;
  };

  programs.zsh = on // {
    enableCompletion = true;
    enableVteIntegration = true;
    autosuggestion = on;
    syntaxHighlighting = on;

    defaultKeymap = "emacs";
    initContent = ''
      zstyle ':completion:*' menu select
      export PATH=$PATH:~/.cargo/bin

      ATUIN_NOBIND=true
      bindkey '^r' _atuin_search_widget

      mcd () { mkdir -pv "$@"; cd "$@"; }
      np() { nix build nixpkgs#$1 --no-link --print-out-paths; }
      what() { readlink -f $(which $@); }

      function set_win_title() {
        local cmd=" ($@)"
        if [[ "$cmd" == " (starship_precmd)" || "$cmd" == " ()" ]]
        then
          cmd=""
        fi
        if [[ $PWD == $HOME ]]
        then
          if [[ $SSH_TTY ]]
          then
            echo -ne "\033]0; [ssh] @ $HOST ~$cmd\a" < /dev/null
          else
            echo -ne "\033]0; ~$cmd\a" < /dev/null
          fi
        else
          BASEPWD=$(basename "$PWD")
          if [[ $SSH_TTY ]]
          then
            echo -ne "\033]0; [ssh] $PWD @ $HOST $cmd\a" < /dev/null
          else
            echo -ne "\033]0; $PWD $cmd\a" < /dev/null
          fi
        fi

      }
      starship_precmd_user_func="set_win_title"
      precmd_functions+=(set_win_title)

      # add some library to LD_LIBRARY_PATH
      ldnix() {
        # since we already use nix-ld, we can reuse the NIX_LDFLAGS
          export LD_LIBRARY_PATH=$(
              nix eval nixpkgs\#legacyPackages.x86_64-linux --raw --apply "s: with s; lib.makeLibraryPath [ $(echo $@) ]"
          ):$LD_LIBRARY_PATH;
      }

    '';
    shellAliases = {
      l = lib.mkDefault "ls -hal";
      nix-search = "nix search --offline nixpkgs";
      ag = "rg"; # on the home row!
    };

    history = {
      extended = true;
      ignoreDups = true;
      size = 10000000;
      save = 10000000;
    };

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "af6f8a266ea1875b9a3e86e14796cadbe1cfbf08";
          sha256 = "BjgMhILEL/qdgfno4LR64LSB8n9pC9R+gG7IQWwgyfQ=";
        };
      }
    ];

  };
}
