{ pkgs, config, ... }: {

  config = {
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
    home-manager.users = {

      root = {
        imports = [
          ./user-shell.nix
        ];
      };

      "${config._.user}" = {
        imports = [
          ./user-shell.nix
          ../../home.nix
        ];
      };

    };

  };
}
