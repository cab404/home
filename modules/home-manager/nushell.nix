args @ { pkgs, lib, ... }:
let
  on = { enable = true; };
  custom_completions = pkgs.fetchFromGitHub {
    rev = "3568fba7e96228a6d5afc9613f7ab0f29ab8cde6";
    hash = "sha256-cwAAtNW5fVEHZ/fHxiYeFVppCJnOEQClMAz2mZ6mpok=";
    owner = "cab404";
    repo = "nu_scripts";
  };
in
{
  home.packages = [ pkgs.nushell ];

  home.shell.enableNushellIntegration = true;

  programs.nushell = on // {

    configFile.text = ''

      # Doesn't work. Yet.
      # https://github.com/nushell/nushell/issues/16106
      # $env.CARAPACE_UNFILTERED = "1"
      $env.CARAPACE_LENIENT = 1

      $env.config.show_banner = false
      $env.config.completions.algorithm = "fuzzy"

      ${ with builtins;
        [ "man" ]#[ "pass" "ssh" "make" "nix" "gh" "curl" "cargo" "claude" "rg" "adb" "man" "yarn" ]
        |> map (prog: "source ${custom_completions}/custom-completions/${prog}/${prog}-completions.nu")
        |> concatStringsSep "\n"
      }

      def mcd ( p: path = ./. ) {
        mkdir -v $p; cd $p;
      }

      def what (cmd: string) {
        which $cmd | get path | path expand
      }

      def l ( p: path = ./. ) {
        ls -l $p | select type name mode user group size modified | sort-by type
      }

      def la ( p: path = ./. ) {
        ls -la $p | select type name mode user group size modified | sort-by type
      }
    '';

    shellAliases = {
      nix-shell = "nix-shell --command nu";
      nix-search = "nix search --offline nixpkgs";
      ag = "rg"; # on the home row!
    };

  };
}
