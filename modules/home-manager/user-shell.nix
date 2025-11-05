args @ { sysconfig, config, pkgs, lib, ... }:
with import ../../lib.nix args;
{

  home.stateVersion = sysconfig.system.stateVersion;
  home.keyboard =
    {
      layout = sysconfig.services.xserver.xkb.layout;
      options = with builtins;
        filter isString (split "," sysconfig.services.xserver.xkb.options);
    };
  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    ripgrep
    socat
    bat
    fzf
    file
    jq
    jless
    ranger
    btop
    nushell
  ];

  home.shellAliases = {
    "nfb" = "nix build --no-link --print-out-paths";
    "nfl" = "nix flake lock --update-input";
    "ns" = "nix search --offline nixpkgs";
    "nm" = "nmcli";
    "z" = "zeditor";
    "z." = "zeditor .";
    "vi" = "hx";
  };

  programs =
    let
      onWithShell = on // {
        enableNushellIntegration = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };
    in
    {
      man.generateCaches = true;

      carapace = onWithShell;

      nushell = on // {
        configFile.text = ''
          $env.config.show_banner = false
        '';
        shellAliases = {
          nix-search = "nix search --offline nixpkgs";
          ag = "rg"; # on the home row!
        };


      };

      bat = on;

      # Nushell doesn't need a better ls
      eza = on // {
        enableZshIntegration = true;
        enableBashIntegration = true;
        enableNushellIntegration = false;
      };

      direnv = on // { nix-direnv = on; };

      keychain = onWithShell // {
        keys = [ ];
      };

      # Too damn verbose!
      # nix-index = onWithShell;

      atuin = onWithShell // {
        flags = [
          "--disable-up-arrow"
        ];
        settings = {
          search_mode = "fuzzy";
          inline_height = 20;
          style = "compact";
        };
      };

      # Fuzzy file search (Ctrl-T for files; Alt-C for dirs)
      fzf =
        let
          # locate doesn't search at home, and that would be insecure.
          # so yeah
          ultimacate = pkgs.writeScript "l" ''
            #!/usr/bin/env bash
            locate $PWD
          '';
        in
        {
          enableZshIntegration = true;
          enableBashIntegration = true;
          fileWidgetCommand = toString ultimacate;
        };


      starship = onWithShell // {
        settings = {
          character.success_symbol = "[δ](dimmed green)";
          character.error_symbol = "[δ](bold red)";
          time = {
            disabled = false;
            format = "[$time]($style)";
            time_format = "%H:%M";
          };
          # too many shells
          shell = {
            disabled = false;
          };
          battery = {
            full_symbol = "";
            charging_symbol = "+";
            discharging_symbol = "-";
            unknown_symbol = "?";
            empty_symbol = "X";
            format = "[$symbol$percentage]($style)";
            display = [
              { style = "red"; threshold = 15; }
              { style = "dimmed red"; threshold = 50; }
              { style = "dimmed green"; threshold = 99; }
              { style = "bold green"; threshold = 100; }
            ];
          };
        };
      };

      helix = on // {
        settings = {
          theme = "base16-transparent";
          editor = {
            # I want to believe
            # whitespace.render = "trailing";
            lsp.display-messages = true;
            cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "underline";
            };
          };
          keys.normal = {
            space.space = "file_picker";
            space.q = ":q";
            esc = [ "collapse_selection" "keep_primary_selection" ];
          };
        };
      };

      # eats way too much cpu :\
      # zellij = on // {
      #   enableZshIntegration = true;
      #   enableBashIntegration = true;
      #   settings = {
      #   };
      # };

      # Well, I still use it from time to time
      bash = on // {
        enableVteIntegration = true;
      };

      zsh = on // {
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

    };

}
