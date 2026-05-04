args @ { sysconfig, config, pkgs, lib, ... }:
with import ../../lib.nix args;
{

  imports = [
    ./zsh.nix
    ./nushell.nix
  ];

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
  ];

  home.shell.enableBashIntegration = true;
  home.shellAliases = {
    "nfb" = "nix build --no-link --print-out-paths";
    "nfl" = "nix flake update";
    "ns" = "nix search --offline nixpkgs";
    "nm" = "nmcli";
    "z" = "zeditor";
    "z." = "zeditor .";
    "vi" = "hx";
  };

  programs = {
      man.generateCaches = true;

      # carapace = on;

      # digits digits digits numbers
      numbat = on;
      carapace = on;

      direnv = on // { nix-direnv = on; };

      keychain = on // {
        keys = [ ];
      };

      # Too damn verbose!
      # nix-index = on;

      atuin = on // {
        flags = [
          "--disable-up-arrow"
        ];
        # daemon.enable = true;
        settings = {
          # search_mode = "daemon-fuzzy";
          search_mode = "fuzzy";
          inline_height = 20;
          sync.records = true;
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

      # zellij = on // {
      #   enableZshIntegration = false;
      #   enableBashIntegration = false;
      #   settings = {
      #   };
      # };

      # Well, I still use it from time to time
      bash = on // {
        enableVteIntegration = true;
      };

    };

}
