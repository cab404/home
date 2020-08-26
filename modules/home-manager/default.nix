{ pkgs, config, ... }:
let
  sources = import ../../nix/sources.nix;
  home-manager = toString sources.home-manager;
in
{

  imports = [ (home-manager + "/nixos") ];
  config = {
    home-manager.useUserPackages = true;
    home-manager.users = {

      root = {
        imports = [
          ./user-shell.nix
        ];
      };

      # "${config._.user}" = {
      #   imports = [
      #     ./user-shell.nix
      #     ../../home.nix
      #   ] ++ (if config._.desktop == null then [] else [
      #     (./.. + "/${config._.desktop}/home.nix")
      #   ]);
      # };

    };
  };
}
