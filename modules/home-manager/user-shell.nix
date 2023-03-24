args @ { sysconfig, config, pkgs, lib, ... }:
with import ../../lib.nix args;
{

  home.stateVersion = "22.05";
  home.keyboard =
    {
    layout = sysconfig.services.xserver.layout;
    options = with builtins;
      filter isString (split "," sysconfig.services.xserver.xkbOptions);
  };

  home.packages = with pkgs; [
    ripgrep
    bat
    fzf
    file
    jq
    jless
    ranger
    btop
  ];

  home.shellAliases = {
    "nfb" = "nix build --no-link --print-out-paths";
    "nfl" = "nix flake lock --update-input";
    "ns" = "nix search --offline nixpkgs";
    "nm" = "nmcli";
  };

  programs = let
    onWithShell = on // {
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  in {

    git = on;

    direnv = on // { nix-direnv = on; };

    keychain = onWithShell // {
      keys = [];
      agents = [ "gpg" "ssh" ];
    };

    # Too damn verbose!
    # nix-index = onWithShell;

    # atuin = onWithShell // {
    #   settings = {
    #     search_mode = "fuzzy";
    #   };
    # };

    # Fuzzy file search (Ctrl-T for files; Alt-C for dirs)
    fzf = let
      # locate doesn't search at home, and that would be insecure.
      # so yeah
      ultimacate = pkgs.writeScript "l" ''
            #!/usr/bin/env bash
            locate $PWD
          '';
    in onWithShell // {
      fileWidgetCommand = toString ultimacate;
    };


    starship = onWithShell // {
      settings = {
        character.success_symbol = "[δ](dimmed green)";
        character.error_symbol = "[δ](bold red)";
        time = {
          disabled = false;
          format= "[$time]($style)";
          time_format = "%H:%M";
        };
        battery = {
          full_symbol = "";
          charging_symbol = "+";
          discharging_symbol = "-";
          unknown_symbol = "?";
          empty_symbol = "X";
          format = "[$symbol$percentage]($style)";
          display = [
            {style = "red"; threshold = 15;}
            {style = "dimmed red"; threshold = 50;}
            {style = "dimmed green"; threshold = 99;}
            {style = "bold green"; threshold = 100;}
          ];
        };
      };
    };

    neovim = on // {
      viAlias = true;
      extraConfig = ''
      :set expandtab
      :set tabstop=4
      :set shiftwidth=4
      '';
    };

    # Well, I still use it from time to time
    bash = on // {
      enableVteIntegration = true;
    };

    zsh = on // {
      enableCompletion = true;
      enableVteIntegration = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;

      defaultKeymap = "emacs";
      initExtra = ''
      zstyle ':completion:*' menu select
      export PATH=$PATH:~/.cargo/bin

      # ATUIN_NOBIND=true
      # bindkey '^r' _atuin_search_widget

      mcd () { mkdir -pv "$@"; cd "$@"; }
      function np() { nix build nixpkgs#$1 --no-link --print-out-paths }

      '';
      shellAliases = {
        l = lib.mkDefault "ls -hal";
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
