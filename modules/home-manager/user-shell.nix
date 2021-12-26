args @ { config, pkgs, lib, ... }:
with import ../../lib.nix args;
{

  programs = enableThings [
    "git"
    "direnv"
    "fzf"
    "starship"
    "zsh"
    "neovim"
  ] {

    direnv.nix-direnv.enable = true;

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

    neovim = {
      package = pkgs.neovim-nightly;
      coc.enable = true;
      viAlias = true;
      withNodeJs = true;
      withPython3 = true;
      extraConfig = ''
      :set expandtab
      :set tabstop=4
      :set shiftwidth=4
      '';
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
        ls = "ls --color=auto";
        ll = "ls -hal";
        l = "ll";
      };
      history = {
        extended = true;
        ignoreDups = true;
        size = 10000000;
        save = 10000000;
        share = true;
      };

    };

  };

  systemd.user = {

    # Locatedb for faster fzf completion
    # TODO: try making tracker work

    services.home-locatedb = {
      Service.Environment = "PATH=$PATH:${pkgs.gnused}/bin:${pkgs.coreutils}/bin";
      Unit.Description = "Local locatedb update for fzf";
      Service.ExecStart = "${pkgs.findutils}/bin/updatedb --localpaths='/home/cab' --output=.locate.db";
    };

    timers.home-locatedb = {
      Unit.Description = "Local file DB updates";
      Unit.PartOf="home-locatedb.service";
      Timer.OnUnitActiveSec = "1d";
      Timer.OnBootSec = "15min";
      Install.WantedBy = [ "timers.target" ];
    };

  };

}
