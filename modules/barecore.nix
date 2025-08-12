# This is a small dump of useful options I prefer everywhere.

{ config, pkgs, lib, prelude, ... }: with prelude; let __findFile = prelude.__findFile; in {

  # ====== NixOS system-level stuff
  system.stateVersion = "23.11";
  require = [ ./options.nix ];

  i18n.defaultLocale = "C.UTF-8";

  imports = [
    <modules/recipes/ssh.nix>

    # ====== User configuration
    {
        users = {
            mutableUsers = false;
            users."${config._.user}" = {
                isNormalUser = true;
                extraGroups = [
                    "wheel"
                    "containers"
                    "networkmanager"
                    "plugdev"
                    "dialout"
                    "video"
                ];
                shell = pkgs.nushell;
            };
            users.root.shell = pkgs.nushell;
            defaultUserShell = pkgs.nushell;
        };

        programs = {
          zsh = on // {
            enableCompletion = true;
          };
          bash.completion.enable = true;
        };

        environment.variables = { EDITOR = "hx"; };

    }
    # ====== Console
    {
        console = {
            colors = [
                "3A3C43" "BE3E48" "869A3A" "C4A535"
                "4E76A1" "855B8D" "568EA3" "B8BCB9"
                "888987" "FB001E" "0E712E" "C37033"
                "176CE3" "FB0067" "2D6F6C" "FCFFB8"
            ];
        };
    }
    # ====== Keyboard
    {
      services.xserver.xkb = {
        layout = "us,ru";
        options = "ctrl:nocaps,lv3:ralt_switch_multikey,misc:typo,grp:rctrl_switch";
      };
      console = {
        packages = [ pkgs.kbd ];
        useXkbConfig = true; # ctrl:nocaps at last
      };
    }
    # ====== Nix config stuff
    {
      nix = {
        package = pkgs.nixVersions.latest;
        settings = {
          trusted-users = [ "root" config._.user ];
          experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
        };
      };
    }
    # ====== Nixpkgs registry hack^W pinning
    {
      nix = {
        # This pins nixpkgs from the flake.lock system-wide both in registry and NIX_PATH
        nixPath = [ "nixpkgs=${pkgs.path}" ];
        registry =
          let
            lock = (with builtins; fromJSON (readFile ../flake.lock));
          in
          {
            nixpkgs =  lib.mkForce (with lock.nodes.${lock.nodes.${lock.root}.inputs.nixpkgs}; {
              from = { id = "nixpkgs"; type = "indirect"; };
              to = locked;
            });
          };
      };
    }

    # ====== Packages
    {

      environment.defaultPackages = (with pkgs; [
        # this section is a tribute to my PEP-8 hatred
        curl htop git tmux  # why aren't those there by default?
        killall usbutils pciutils zip unzip # WHY AREN'T THOSE THERE BY DEFAULT?
        nmap arp-scan rsync
        waypipe # way to ssh -X, but wayland

        helix vim # Vim is rarely needed, but still needed sometimes

        nix-index # woo, search in nix packages files!

      ]);

    }

  ];

}
