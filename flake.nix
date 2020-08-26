{
  description = "cab's system config";

  inputs = {
    home-manager = {
      url = "github:rycee/home-manager/release-20.03";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager }: {

    nixosConfigurations = {
      yuna = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configuration.nix ];
      };
    };
  };
}
