{
  description = "cab's system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }: {

    nixosConfigurations = {

      yuna =
        let
          inherit (nixpkgs) lib;
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
          ];
        in lib.nixosSystem {
          inherit modules system specialArgs;
        };

    };

  };

}
