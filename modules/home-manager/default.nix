{ pkgs, config, inputs, ... }: {

  imports = [
    ../options.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
    home-manager.extraSpecialArgs = {
      inherit inputs;
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
