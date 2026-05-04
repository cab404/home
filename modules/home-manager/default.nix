{ pkgs, config, inputs, prelude, P, ... }: {

  imports = [
    ../options.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
    # home-manager.backupFileExtension = "bck";
    home-manager.extraSpecialArgs = {
      inherit inputs prelude P;
      sysconfig = config;
    };
    home-manager.users = {

      root = {
        imports = [
          ./user-shell.nix
        ];
      };

      "${config._.user}" = {
        imports = [
          ./user-shell.nix
        ];
      };

    };

  };
}
